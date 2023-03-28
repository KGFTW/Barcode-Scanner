@isTest
public class BarcodeScannerCxTest {
    
    @testSetup
    static void testSetup() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
    }
    
    static testMethod void interpretBarcodeTest() {
        List<Account> accList = [Select Id
                                 From Account];
        system.assert(!accList.isEmpty());
        
        String expectText = 'Test Account Updated';
        String validApiName = 'Name';
        String invalidApiName = 'Nam';
        
        test.startTest();
		String validUpdate = BarcodeScannerCx.interpretBarcode(accList[0].Id, validApiName, expectText);
        String invalidUpdate = BarcodeScannerCx.interpretBarcode(accList[0].Id, invalidApiName, expectText);       
        String errorUpdate = BarcodeScannerCx.interpretBarcode(accList[0].Id, validApiName, '');
        test.stopTest();
        
        system.assertEquals(BarcodeScannerCx.successMsg, validUpdate);
        system.assertEquals(BarcodeScannerCx.invalidApiName, invalidUpdate);
        system.assert(errorUpdate.contains(BarcodeScannerCx.updateError));
    }
    
    static testMethod void getIdSobjectTypeTest() {
		List<Account> accList = [Select Id
                                 From Account];
        system.assert(!accList.isEmpty());
        
        String expectedSoTypeName = accList[0].Id.getSObjectType().getDescribe().getName();
            
        test.startTest();
        String actualSoTypeName = BarcodeScannerCx.getIdSobjectType(accList[0].Id);
        test.stopTest();
        
        system.assertEquals(expectedSoTypeName, actualSoTypeName);
    }
    
    static testMethod void hasSObjectFieldTest() {
        String fieldApiName = 'Name';
        
        Boolean expectedHasField = Account.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldApiName.toLowerCase());
        
        test.startTest();
        Account acc = new Account();
        Boolean actualHasField = BarcodeScannerCx.hasSObjectField(acc, fieldApiName);
        test.stopTest();
        
        system.assertEquals(expectedHasField, actualHasField);
    }
}