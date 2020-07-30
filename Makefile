# See https://developer.apple.com/documentation/xcode/notarizing_macos_software_before_distribution/customizing_the_notarization_workflow
# Assumes that the environemnt variables USERNAME and PASSWORD have appropriate values (see the above link).
prepare: app sign zip upload

app: clean
	@echo "Compiling Singt into a Mac App..."
	pyinstaller --noconsole --additional-hooks-dir=hooks singt.py

sign:
	@echo "Code signing the app..." 
	codesign --verify \
            --verbose \
            --deep \
            --options runtime \
            --sign "${DEVELOPER_ID_CERT_NAME}" \
            dist/singt.app

zip:
	@echo "Zipping..."
	/usr/bin/ditto -c -k --keepParent dist/singt.app dist/singt-to-notarize.app.zip

upload:
	@echo "Uploading..."
	xcrun altool --notarize-app \
                --primary-bundle-id "singt" \
                --username "${USERNAME}" \
                --password "${PASSWORD}" \
                --file dist/singt-to-notarize.app.zip
	@echo "Copy the RequestUUID provided to the ID environment variable"

progress:
	xcrun altool --notarization-history -u "${USERNAME}" --password "${PASSWORD}"

info:
	xcrun altool --notarization-info "${ID}" -u "${USERNAME}" --password "${PASSWORD}"

staple:
	xcrun stapler staple dist/singt.app

clean:
	@echo "Cleaning..."
	rm -rf build
	rm -rf dist
