/*****************************************************************************************
Name: RestCalloutClass_CLS
===============================================================================================
===============================================================================================
Purpose:
--------
This is the handler class for making out REST callouts for processing Transaction Items.
The returned IDs are then processed for making the next payload that processes Transaction Items.
===============================================================================================
History
-------
VERSION        AUTHOR                  	DATE               		DETAILS
1.0            Pavan Kemba         		16th NOV 2020     		Initial Development
===============================================================================================
 ******************************************************************************************/

global class RestCalloutClass_CLS {
    
    public static List<id> transItemList = new List<id>();
    public static String secondPayload;

    // THIS METHOD PROCESSES THE JSON STRING WITH LIST OF IDS AND MAKES A REST CALL OUT
    @future(callout=true)
    public static void makeCallout(String reqBody) {
        if(String.isNotEmpty(reqBody)){
        System.debug('reqBody on makeCallout : '+reqBody);
        List<getDetails> proccessedTIList = new List<getDetails>();       
        //List<id> transItemList = new List<id>();
        	// CREATING HTTP REQUEST INSTANCE TO PREPARE FOR REST CALL
        	Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint('https://test.callout');
			request.setMethod('POST');
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');
			request.setBody(reqBody);
        	// BELOW LINE CALLOUTS THE REST REQUEST
        /* try{
				HttpResponse response = http.send(request);
        	}catch(Exception ex){
        		System.debug('CALLOUT EXCEPTIONs');
    		} */
        	
            Integer responseCode = 200; // TO ASSUME THE RESPONSE TO BE SUCCESS
        //if(response.getStatusCode() == 200){
        	if(responseCode == 200) {
                // PARSE THE RESPONSE AND RETURN IDS OF SUCCESSFUL RECORDS
     
		      	// ASSUMING THE CALL OUT RETURNING THE KEYS (TRANSACTION ITEM IDs) BACK FOR SUCCESSFUL TRANSACTION
      			// COLLECT THOSE IDs TO PROCESS TRANSACTION PAYLOAD NEXT.
      			// WE ARE PARSING THE SAME REQUEST JSON HERE, AND PROCESSING SAME
                try{
                    // PARSING THE JSON FORMAT TO GET THE KEYS(TRASACTIONITEMID)
                    List<getDetails> objSerialized = (List<getDetails>)JSON.deserialize(reqBody,List<getDetails>.class); 
              
                    if(!objSerialized.isEmpty())
                        for(getDetails tI : objSerialized){
                            // CAN HAVE A BOOLEAN CHECK TO INCLUDE ONLY RECORDS THAT WERE SUCCESS
                            transItemList.add(tI.keys.TransactionItemID); // LIST HOLDS THE TRANSACTIONITEMIDs
                        }
                                     
                    if(!transItemList.isEmpty()){
                        System.debug('CALLING THE SECOND PAYLOAD');
                        secondPayload = createSecondPayload(transItemList);
                        System.debug('PRINTING SECOND PAYLOAD : '+secondPayload);
                    }
                }catch(Exception ex){
                    System.debug('Exception While deserializing JSON response');
                    System.debug('Exception msg : '+ex.getMessage()+' at line # : '+ex.getLineNumber()+' - '+ex.getCause());
                }          
    }
    }
   }
    
    
    public class getDetails {
        public keys keys;
       }
    
    public class keys{
        public String TransactionItemID {get;set;}
    }
    
    public static String createSecondPayload(List<id> processIds){
        System.debug('PREPARING 2nd PAYLOAD');
        String TransJSONString;
        System.debug('processIds : '+processIds);
        Set<id> transactionIds = new Set<id>();
        List<Transaction__c> processTransactionRecordsList = new List<Transaction__c>();
        
        for(TransactionItem__c tIL : [SELECT id,Transaction__c FROM TransactionItem__c WHERE id in:processIds]){
            transactionIds.add(tIL.Transaction__c);
        }
        
        System.debug('PRINTING TRANSACTION RECORD IDs : '+transactionIds);
        if(!transactionIds.isEmpty()){
           for(Transaction__c trans : [SELECT id,TotalCost__c,lastModifiedDate,Transaction_Count__c,Total_Cost__c,Total_Discount__c,(SELECT id,Name,Item_Cost__c FROM TransactionItem__r) FROM Transaction__c where ID IN :transactionIds]){
               // PROCESSING ONLY THOSE TRANSACTIONS WHOSE RELATED ITEMS WERE ALL PROCESSED ON FIRST WEBSERVICE CALL 
               if(trans.Transaction_Count__c > 0 && trans.Transaction_Count__c == trans.TransactionItem__r.size()){
                    processTransactionRecordsList.add(trans);
                }
        	}  
        }
        
         //System.debug('PRINTING TRANSACTION RECORD ELIGIBLE : '+processTransactionRecordsList);
        if(!processTransactionRecordsList.isEmpty()){
            TransJSONString = processTransload(processTransactionRecordsList);
        }
       return TransJSONString; 
    }
    
        /*
     * THIS METHOD processSecondPayload PREPARES JSON OF TRANSACTION RECORDS, THAT NEEDS TO BE PROCESSED
     * FOR CALL OUT
     */ 
    public static String processTransload(List<Transaction__c> processTransList){
        System.debug('IN processTransload METHOD');
        String JSONstring;
        JSONGenerator gen = JSON.createGenerator(true);

           for (Transaction__c transRec : processTransList){
              gen.writeStartObject();
        		gen.writeFieldName('keys');
        			gen.writeStartObject();
            			gen.writeFieldName('TransactionID');
            			gen.writeString(transRec.id);
        			gen.writeEndObject();

            	gen.writeFieldName('values');
        			gen.writeStartObject();
            			gen.writeFieldName('TotalCost');
            			gen.writeNumber(transRec.TotalCost__c);     
            			
               			gen.writeFieldName('TotalDiscount');
            			gen.writeNumber(transRec.Total_Discount__c);
               
               			@testvisible
               			DateTime dT = transRec.lastModifiedDate;
						@testvisible
               			Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
               
                        gen.writeFieldName('TransactionDate');
            			gen.writeString(String.valueof(myDate));
               
                        gen.writeFieldName('TotalCount');
            			gen.writeNumber(transRec.Transaction_Count__c);
        			gen.writeEndObject();
           	  gen.writeEndObject();
        }
 
     
     JSONstring = gen.getAsString();
   
     return JSONstring;   
    }
}