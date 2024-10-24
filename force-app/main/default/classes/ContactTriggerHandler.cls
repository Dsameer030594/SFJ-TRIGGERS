public class ContactTriggerHandler {
    
    // Trigger Scenario 7, 17 a. : when a new contact is created for a existing account then set contact otherPhone as account phone.
    public static void setConPhonetoAccPhone(List<Contact> conList){
        // Collect Account Ids for new Contacts
        Set<Id> accIds = new Set<Id>();
        Map<Id, String> accountIdToPhoneMap = new Map<Id, String>();
        for(Contact con : conList){
            if(con.AccountId != null){
                accIds.add(con.AccountId);
            }
        }
        // Retrieve Phone numbers for associated Accounts
        for(Account acc : [Select Id, Name, Phone,(Select Id, AccountId, OtherPhone from Contacts) from Account where Id IN: accIds]){
            accountIdToPhoneMap.put(acc.Id, acc.Phone);
        }
        // Set OtherPhone field for new Contacts
        for(Contact con : conList){
            if(con.AccountId  != null && accountIdToPhoneMap.containsKey(con.AccountId)){
                con.OtherPhone = accountIdToPhoneMap.get(con.AccountId);
            }
        } 
    }
    
    // 20. When the value of AssistantPhone field on contact is updated , 
    // I would like the field value of phone__c the opportunity and phone on account also get updated.
    public static void updateOppAndAccountPhone(List<Contact> conList, Map<Id, Contact> conOldMap){
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id, Contact> conPhoneMap = new Map<Id, Contact>();
        
        for(Contact con : conList){
            if(con.AssistantPhone != conOldMap.get(con.Id).AssistantPhone){
                conPhoneMap.put(con.AccountId, con);
            }
        }
        //Query related Account and Opportunity
        for(Account acc :[Select Id, Phone,(Select Id, AccountId, Phone__c from Opportunities) from Account where Id IN: conPhoneMap.keySet()]){
            acc.Phone = conPhoneMap.get(acc.Id).AssistantPhone;
            accList.add(acc);
            
            for(Opportunity opp : acc.Opportunities){
                opp.Phone__c = conPhoneMap.get(acc.Id).AssistantPhone;
                oppList.add(opp);
            }
        }
        update accList;
        update oppList;
    }
    
    //b.  After Insert trigger for count of contacts rollup on account
    public static void countContactsRolluponAcc(List<Contact> conList, Map<Id, Contact> conOldMap){
        List<Account> accList = new List<Account>();
        //Set<Id> accIds = new Set<Id>();
        Map<Id, Contact> conNewMap = new Map<Id, Contact>();
        
        for(Contact con : conList){
            if(con.AccountId != null){
                // accIds.add(con.AccountId);
                conNewMap.put(con.AccountId, con);
            }
        }
        
        for(Account acc : [Select Id, Name,(Select Id, AccountId, lastName from Contacts) from Account where Id IN: conNewMap.keySet()]){  //OR accIds
            if(conNewMap.containsKey(acc.Id)){   // OR accIds.contains(acc.Id)
                acc.Total_Contacts_Count__c = acc.Contacts.size();
                accList.add(acc); 
            }   
        }
        
        update accList;
    }
    // c. Duplicate check on existing contact if phone number is already present
    public static void duplicateCheckonExistingCon(List<Contact> conList){
        Set<String> oldPhoneNumber = new Set<String>();
        Set<String> newPhoneNumber = new Set<String>();
        
        for(Contact con : conList){
            if(conList != null && con.Phone != null){
                oldPhoneNumber.add(con.Phone); 
            }
        }
        
        for(Contact con :[Select Id, AccountId, Phone, lastName from Contact where Phone IN: oldPhoneNumber]){
            if(oldPhoneNumber.contains(con.AccountId)){
                newPhoneNumber.add(con.Phone);
            }  
        }
        
        for(Contact con : conList){
            if(con.AccountId != null && newPhoneNumber.contains(con.AccountId)){
                con.addError('Duplicate Phone Number!');
            }
        }
    }
}