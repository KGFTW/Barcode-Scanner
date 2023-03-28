/*
@className    BarcodeScannerCx
@testClass    BarcodeScannerCxTest
@description  This is the Barcode Scanner LWC apex class controller that interprets it based on the provided field api name
@author		  KG
@todo		  None.
*/
public with sharing class BarcodeScannerCx {

    @testVisible
    static final String successMsg = 'Success';
    @testVisible
    static final String invalidApiName = 'Provided field doesn\'t exist for the provided sobject. Please Update the component configuration to match a compatible text field.';
    @testVisible
    static final String updateError = 'An error occured during the update:';
	@testVisible
    static final String unexpectedError = 'An unexpected error occured during the process.';
    
    /**
     * @param recordId: id of the record to inject the barcode result into
     * @param fieldApiName: api name of the field on which to inject the barcode result into
     * @param barcodeText: the barcode text that was decoded
     * @return: returns either a success or an error message
     */
    @AuraEnabled
    public Static String interpretBarcode(Id recordId, String fieldApiName, String barcodeText) {
        try {
            // First retrieve the sobject type from the record Id 
            String sObjectType = recordId.getSObjectType().getDescribe().getName();
            // Then instanciate an sObject from its type
            sObject so = Schema.getGlobalDescribe().get(sObjectType).newSObject();
            String result = invalidApiName;
            if(hasSObjectField(so, fieldApiName)) {
                // Set the record id and field api name accordingly
                so.put('Id', recordId);
                so.put(fieldApiName, barcodeText);
                Database.SaveResult sr = database.update(so,false);
                result = sr.isSuccess() ? successMsg : updateError;
                if (!sr.isSuccess()) {
                    result = updateError;
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        result += err.getStatusCode() + ': ' + err.getMessage();   
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
            return result;
        }catch(Exception e) {
            throw new AuraHandledException(unexpectedError);
        }
    }

    /**
     * @param recordId: id of the record to get the sobject type from
     * @return: returns the record sobject type
     */
    public static String getIdSobjectType(Id recordId) {
        return recordId.getSObjectType().getDescribe().getName();
    }

    /**
     * @param so: sobject instance
     * @param fieldName: api name of the field to verify existence on provided sobject
     * @return: returns either the provided field exists on the provided sobject
     */
    public static boolean hasSObjectField(SObject so, String fieldName){
        return so.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldName.toLowerCase());
    }
}