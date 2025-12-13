%-signed.apk: %-unsigned.apk
	/opt/android-sdk/build-tools/*/apksigner \
		sign \
		--key "/opt/snakeoil/key.pk8" \
		--cert "/opt/snakeoil/cert.pem" \
		--in "$(<)" \
		--out "$(@)"
