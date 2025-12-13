// SPDX-License-Identifier: Apache-2.0 OR MIT

use btleplug::api::bleuuid::BleUuid;
use btleplug::api::{Central, CentralEvent, Manager as _, Peripheral as _, ScanFilter};
use btleplug::platform::Manager;
use futures::stream::StreamExt;
use log::info;

#[cfg(target_os = "windows")]
#[global_allocator]
static GLOBAL: mimalloc::MiMalloc = mimalloc::MiMalloc;

#[tokio::main]
async fn main() {
    env_logger::init_from_env(env_logger::Env::new().filter_or("RUST_LOG", "debug"));

    let manager = Manager::new().await.unwrap();
    let mut adapters = manager.adapters().await.unwrap();
    info!("Found {} Bluetooth adapters:", adapters.len());
    for adapter in adapters.iter() {
        let info = adapter.adapter_info().await.unwrap();
        info!("    {}", info);
    }

    let adapter = adapters.pop().unwrap();
    let mut events = adapter.events().await.unwrap();
    adapter.start_scan(ScanFilter::default()).await.unwrap();

    while let Some(event) = events.next().await {
        match event {
            CentralEvent::DeviceDiscovered(id) => {
                let peripheral = adapter.peripheral(&id).await.unwrap();
                let properties = peripheral.properties().await.unwrap();
                let name = properties.and_then(|p| p.local_name).unwrap_or_default();
                info!("BLE device discovered: {:?} ({:?})", name, id.to_string());
            }

            CentralEvent::StateUpdate(state) => {
                info!("BLE adapter state update: {:?}", state);
            }

            CentralEvent::DeviceConnected(id) => {
                info!("BLE device connected: {:?}", id.to_string());
            }

            CentralEvent::DeviceUpdated(id) => {
                info!("BLE device updated: {:?}", id.to_string());
            }

            CentralEvent::DeviceDisconnected(id) => {
                info!("BLE device disconnected: {:?}", id.to_string());
            }

            CentralEvent::ManufacturerDataAdvertisement {
                id,
                manufacturer_data,
            } => {
                info!(
                    "BLE manufacturer data advertisement: {:?}, {:?}",
                    id.to_string(),
                    manufacturer_data
                );
            }

            CentralEvent::ServiceDataAdvertisement { id, service_data } => {
                info!(
                    "BLE service data advertisement: {:?}, {:?}",
                    id.to_string(),
                    service_data
                );
            }

            CentralEvent::ServicesAdvertisement { id, services } => {
                let services: Vec<String> =
                    services.into_iter().map(|s| s.to_short_string()).collect();
                info!(
                    "BLE services advertisement: {:?}, {:?}",
                    id.to_string(),
                    services
                );
            }
        }
    }
}
