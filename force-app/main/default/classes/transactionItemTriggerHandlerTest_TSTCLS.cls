@isTest
public class transactionItemTriggerHandlerTest_TSTCLS {
    
    private static Transaction__c trans;
    
    static testMethod void firstMethod(){
        List<TransactionItem__c> tItemList = new List<TransactionItem__c>(); 
        
        trans = TestUtility.createTransaction('Test',2);
        trans.Total_Discount__c = 8.6;   
        test.startTest();
        insert trans;
        
		TransactionItem__c transItem1 = TestUtility.createTransactionItem(trans.id);        
        tItemList.add(transItem1);
        
        TransactionItem__c transItem2 = TestUtility.createTransactionItem(trans.id);
        transItem2.Item_Cost__c = null;
        tItemList.add(transItem2);
              
        insert tItemList;
        
        
        Transaction__c upTrans = [Select id,Transaction_Count__c FROM Transaction__c WHERE id=:trans.id];
        upTrans.Total_Cost__c = 45.0;
        update upTrans;
        
        test.stopTest();
        Transaction__c transRec = [SELECT id,TotalCost__c,Transaction_Count__c,Total_Discount__c FROM Transaction__c WHERE id =: trans.id];
        System.assertEquals(trans.Transaction_Count__c,transRec.Transaction_Count__c);
       // System.assertEquals(expected, actual)
        
        //delete transItem3;
        
    }
    
        static testMethod void secondMethod(){
        List<TransactionItem__c> tItemList = new List<TransactionItem__c>(); 
        
        trans = TestUtility.createTransaction('Test',0);
        trans.Total_Discount__c = 8.6;   
        test.startTest();
        insert trans;
        
		TransactionItem__c transItem1 = TestUtility.createTransactionItem(trans.id);        
        tItemList.add(transItem1);
                    
        insert tItemList;
                
        Transaction__c upTrans = [Select id,Transaction_Count__c FROM Transaction__c WHERE id=:trans.id];
        upTrans.Total_Cost__c = 45.0;
        //upTrans.Transaction_Count__c = 1;
        update upTrans;
        
       
        delete transItem1;
        test.stopTest();
        
    }
}