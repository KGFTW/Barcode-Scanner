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
    static final String upsertError = 'An error occured during the update:';
	@testVisible
    static final String unexpectedError = 'An unexpected error occured during the process.';
    
    /**
     * @param recordId: id of the record to inject the barcode result into
     * @param childsObjectApiName: api name of the child object for which to create a record
     * @param fieldApiName: api name of the field on which to inject the barcode result into
     * @param barcodeText: the barcode text that was decoded
     * @return: returns either a success or an error message
     */
    @AuraEnabled
    public Static String interpretBarcode(Id recordId, String childsObjectApiName, String relationFieldApiName, String fieldApiName, String barcodeText) {
        try {
            // Set the sObjectType based on the child sObject Api Name presence
            String sObjectType = String.isBlank(childsObjectApiName) ? recordId.getSObjectType().getDescribe().getName() : childsObjectApiName;
            // Then instanciate an sObject from its type
            sObject so = Schema.getGlobalDescribe().get(sObjectType).newSObject();
            String result = invalidApiName;
            if(hasSObjectField(so, fieldApiName)) {
                // Set the id field (being the record Id or child record parent id)
                String idField = (String.isBlank(childsObjectApiName) && String.isBlank(relationFieldApiName)) ? 'Id' : relationFieldApiName;
                // And put it on the record
                so.put(idField, recordId);
                // Set the field value accordingly based on the barcode content
                so.put(fieldApiName, barcodeText);
                Database.UpsertResult ur = database.upsert(so,false);
                result = ur.isSuccess() ? successMsg : upsertError;
                if (!ur.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : ur.getErrors()) {
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