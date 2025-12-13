// SPDX-License-Identifier: Apache-2.0 OR MIT

#![no_std]
#![no_main]

use ::cyw43::Control;
use ::cyw43_pio::{PioSpi, RM2_CLOCK_DIVIDER};
use ::defmt::unwrap;
use ::defmt_rtt as _;
use ::embassy_executor::Spawner;
use ::embassy_futures::select::select;
use ::embassy_rp::bind_interrupts;
use ::embassy_rp::gpio::{Level, Output};
use ::embassy_rp::peripherals::{DMA_CH0, PIO0};
use ::embassy_rp::pio::{InterruptHandler, Pio};
use ::embassy_rp::spi::{self, Spi};
use ::embassy_time::{Delay, Duration, Timer};
use ::embedded_graphics::Drawable;
use ::embedded_graphics::mono_font::MonoTextStyleBuilder;
use ::embedded_graphics::mono_font::ascii::FONT_6X10;
use ::embedded_graphics::pixelcolor::BinaryColor;
use ::embedded_graphics::prelude::{Point, Primitive};
use ::embedded_graphics::primitives::{PrimitiveStyle, Triangle};
use ::embedded_graphics::text::{Baseline, Text};
use ::oled_async::prelude::DisplayRotation;
use ::panic_probe as _;
use ::rand::rngs::SmallRng;
use ::rand::{Rng, SeedableRng};
use ::static_cell::StaticCell;
use ::trouble_host::prelude::ExternalController;

mod peripheral;

// Program metadata for `picotool info`.
// This isn't needed, but it's recommended to have these minimal entries.
#[unsafe(link_section = ".bi_entries")]
#[used]
pub static PICOTOOL_ENTRIES: [embassy_rp::binary_info::EntryAddr; 4] = [
    embassy_rp::binary_info::rp_program_name!(c"Blinky Example"),
    embassy_rp::binary_info::rp_program_description!(
        c"This example tests the RP Pico 2 W's onboard LED, connected to GPIO 0 of the cyw43 \
        (WiFi chip) via PIO 0 over the SPI bus."
    ),
    embassy_rp::binary_info::rp_cargo_version!(),
    embassy_rp::binary_info::rp_program_build_attribute!(),
];

bind_interrupts!(struct Irqs {
    PIO0_IRQ_0 => InterruptHandler<PIO0>;
});

#[embassy_executor::task]
async fn cyw43_task(
    runner: cyw43::Runner<'static, Output<'static>, PioSpi<'static, PIO0, 0, DMA_CH0>>,
) -> ! {
    runner.run().await
}

#[embassy_executor::main]
async fn main(spawner: Spawner) {
    let p = embassy_rp::init(Default::default());
    let fw = include_bytes!("../cyw43-firmware/43439A0.bin");
    let clm = include_bytes!("../cyw43-firmware/43439A0_clm.bin");
    let btfw = include_bytes!("../cyw43-firmware/43439A0_btfw.bin");

    // To make flashing faster for development, you may want to flash the firmwares independently
    // at hardcoded addresses, instead of baking them into the program with `include_bytes!`:
    //     probe-rs download ../../cyw43-firmware/43439A0.bin --binary-format bin --chip RP235x --base-address 0x10100000
    //     probe-rs download ../../cyw43-firmware/43439A0_clm.bin --binary-format bin --chip RP235x --base-address 0x10140000
    //let fw = unsafe { core::slice::from_raw_parts(0x10100000 as *const u8, 230321) };
    //let clm = unsafe { core::slice::from_raw_parts(0x10140000 as *const u8, 4752) };

    let pwr = Output::new(p.PIN_23, Level::Low);
    let cs = Output::new(p.PIN_25, Level::High);
    let mut pio = Pio::new(p.PIO0, Irqs);
    let spi = PioSpi::new(
        &mut pio.common,
        pio.sm0,
        // SPI communication won't work if the speed is too high, so we use a divider larger than `DEFAULT_CLOCK_DIVIDER`.
        // See: https://github.com/embassy-rs/embassy/issues/3960.
        RM2_CLOCK_DIVIDER,
        pio.irq0,
        cs,
        p.PIN_24,
        p.PIN_29,
        p.DMA_CH0,
    );

    static STATE: StaticCell<cyw43::State> = StaticCell::new();
    let state = STATE.init(cyw43::State::new());
    let (_net_device, bt_device, mut control, runner) =
        cyw43::new_with_bluetooth(state, pwr, spi, fw, btfw).await;
    unwrap!(spawner.spawn(cyw43_task(runner)));

    control.init(clm).await;
    control
        .set_power_management(cyw43::PowerManagementMode::Performance)
        .await;

    let controller: ExternalController<_, 10> = ExternalController::new(bt_device);

    // OLED
    // TODO: Initially High or Low?
    let cs = Output::new(p.PIN_14, Level::High);
    let dc = Output::new(p.PIN_13, Level::High);
    let mut reset = Output::new(p.PIN_12, Level::High);
    let mosi = p.PIN_11;
    let clk = p.PIN_10;

    let mut spi_config = spi::Config::default();
    spi_config.frequency = 4_000_000; // 4 MHz
    let spi = Spi::new_txonly(p.SPI1, clk, mosi, p.DMA_CH1, spi_config);

    let spi = unwrap!(embedded_hal_bus::spi::ExclusiveDevice::new(spi, cs, Delay));

    let di = display_interface_spi::SPIInterface::new(spi, dc);

    let mut delay = Delay {};

    let raw_disp = oled_async::Builder::new(oled_async::displays::sh1106::Sh1106_128_64 {})
        .with_rotation(DisplayRotation::Rotate180)
        .connect(di);

    let mut disp: oled_async::mode::GraphicsMode<_, _> = raw_disp.into();

    unwrap!(disp.reset(&mut reset, &mut delay));
    unwrap!(disp.init().await);
    disp.clear();
    unwrap!(disp.flush().await);

    // Run everything.
    let a = peripheral::run(controller);
    let b = led_blink(control);
    let c = display(disp);
    select(select(a, b), c).await;
}

async fn led_blink(mut control: Control<'_>) {
    let delay = Duration::from_millis(250);
    loop {
        control.gpio_set(0, true).await;
        Timer::after(delay).await;

        control.gpio_set(0, false).await;
        Timer::after(delay).await;
    }
}

async fn display<DV, DI>(mut disp: oled_async::mode::GraphicsMode<DV, DI>)
where
    DI: display_interface::AsyncWriteOnlyDataCommand,
    DV: oled_async::display::DisplayVariant,
{
    let text_style = MonoTextStyleBuilder::new()
        .font(&FONT_6X10)
        .text_color(BinaryColor::On)
        .build();
    let text = Text::with_baseline("Hello world!", Point::zero(), text_style, Baseline::Top);

    let delay = Duration::from_millis(50);
    let mut rng = SmallRng::seed_from_u64(12345);

    loop {
        let triangle = Triangle::new(
            Point::new(rng.random_range(0..128), rng.random_range(11..64)),
            Point::new(rng.random_range(0..128), rng.random_range(11..64)),
            Point::new(rng.random_range(0..128), rng.random_range(11..64)),
        )
        .into_styled(PrimitiveStyle::with_stroke(BinaryColor::On, 1));

        disp.clear();

        unwrap!(text.draw(&mut disp));
        unwrap!(triangle.draw(&mut disp));
        unwrap!(disp.flush().await);

        Timer::after(delay).await;
    }
}
