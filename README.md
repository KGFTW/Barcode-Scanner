# Barcode Scanner LWC

<a href="https://githubsfdeploy.herokuapp.com?owner=KGFTW&repo=Barcode-Scanner">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

# Documentation

This component facilitates the scan of any supported barcode type (<a href="https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_barcodescanner_compatibility">list provided by Salesforce</a>) to help Salesforce end-users to scan and get the content from said barcode into a record field.

This component is generic and can be used with and on any sObject.
    
# How to use it ?
It's quite simple, follow these steps:
    
- First get to a record page of any object.
- Add the component to the page anywhere you want end-users to be able to access the "Click to Scan" button.
- Configure the component parameters, they're quite self-explanatory.
- Voilà !

N.B.: the target field must be a text field for the decoded content to be pushed into it properly, otherwise you'll need to tweak out the code yourself.

# How it works
The LWC leverages the Salesforce <a href="https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_barcodescanner">Barcode Scanner library</a> to actually scan and decode the barcode content.
Based on the provided "Field Api Name" parameter and current record Id, the apex code gets the sObject, verifies if the field exists in it, then pushes the scanned barcode content into it.
