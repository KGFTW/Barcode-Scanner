import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import interpretBarcode from '@salesforce/apex/BarcodeScannerCx.interpretBarcode';

export default class BarcodeScanner extends NavigationMixin(LightningElement) {
	scanner;
	scannedBarcode = '';
	scanButtonDisabled = false;
	scanComplete = false;

	get showComponent() {
		return this.scanner.isAvailable && !this.hideComponentIfNoScanner;
	}
	get showDebugWindow() {
		return this.debug && this.scanComplete;
	}
	get instructionTextStyle() {
		return 'color:${this.instructionsColor};';
	}
	get missingApexClass() {
		return this.actionType === 'Interpret Barcode' && (this.apexClassName === null || this.apexClassName === '');
	}

	@api hideComponentIfNoScanner = false;
	@api cardTitle = 'Barcode Scanner';
	@api buttonLabel = 'Scan Barcode';
	@api instructions = 'Press the button below to open the camera. Position a barcode in the scanner window to scan it.';
	@api instructionsColor = '#888888';
	@api debug = false;
	@api childsObjectApiName;
	@api relationFieldApiName;
    @api fieldApiName;
	@api successMessage = 'Success!';
	@api recordId;

	connectedCallback() {
		this.scanner = getBarcodeScanner();
		this.scanButtonDisabled =
			this.scanner === null || !this.scanner.isAvailable() || this.missingApexClass;
	}

	handleBeginScanClick(event) {
		this.scannedBarcode = '';
		this.scanComplete = false;
		if (this.scanner != null && this.scanner.isAvailable()) {
			this.scanner
				.beginCapture({
					barcodeTypes: [
						this.scanner.barcodeTypes.CODE_128,
						this.scanner.barcodeTypes.CODE_39,
						this.scanner.barcodeTypes.CODE_93,
						this.scanner.barcodeTypes.DATA_MATRIX,
						this.scanner.barcodeTypes.EAN_13,
						this.scanner.barcodeTypes.EAN_8,
						this.scanner.barcodeTypes.ITF,
						this.scanner.barcodeTypes.PDF_417,
						this.scanner.barcodeTypes.QR,
                        this.scanner.barcodeTypes.UPC_A,
						this.scanner.barcodeTypes.UPC_E
					]
				})
				.then((result) => {
					this.scannedBarcode = result.value;
					this.handleBarCode();
				})
				.catch((error) => {
					this.dispatchEvent(
						new ShowToastEvent({
							title: 'Barcode Scan Error',
							message: JSON.stringify(error),
							variant: 'error',
							mode: 'sticky'
						})
					);
				})
				.finally(() => {
					this.scanner.endCapture();
					this.scanComplete = true;
				});
		}
	}

	handleBarCode() {
        interpretBarcode({recordId: this.recordId, childsObjectApiName: this.childsObjectApiName, relationFieldApiName: this.relationFieldApiName, fieldApiName: this.fieldApiName, barcodeText: this.scannedBarcode})
        .then(result => {
            if(result=='Success') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Barcode content added to the ' + this.fieldApiName + ' field:' + this.scannedBarcode,
                        variant: 'success',
                        mode: 'sticky'
                    })
                );
            }else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Error: ' + result,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
            }
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'There was a problem during the scan:',
                    message: error,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        });
    }
}