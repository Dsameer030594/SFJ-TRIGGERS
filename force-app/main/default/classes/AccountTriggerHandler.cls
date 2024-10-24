public class AccountTriggerHandler {
    
    // Triger Scenario 3.Whenever New Account Record is created then needs to create associated Contact Record automatically.
    
    public static void createAssociatedContact(List<Account> accList){
        List<Contact> conList = new List<Contact>();
        
        for(Account acc : accList){
            Contact con = new Contact();
            con.FirstName = 'Test';
            con.LastName =  acc.Name;
            con.AccountId = acc.Id;
            conList.add(con);
        }
        if(!conList.isEmpty()){
            insert conList;
        }
    }
    
    //Triger Scenario 4.Whenever the Account is created with Industry as Banking 
    // then create a contact for account, Contact Lastname as Account name and contact phone 
    // as account phone.
    public static void createAssoContactWithLNamePhoneSame(List<Account> accList){
        List<Contact> conList = new List<Contact>();
        
        for(Account acc : accList){
            if(acc.Industry == 'Banking'){
                Contact con = new Contact();
                con.FirstName = 'Test';
                con.LastName = acc.Name;
                con.Phone = acc.Phone;
                con.AccountId = acc.Id;
                conList.add(con);
            }
            
        }
        if(!conList.isEmpty()){
            insert conList;
        }
    }
    
    // Trigger Scenario 5 : Important scenario
    //Creates the number of contacts which are equal to the number which we will enter in the Number of Locations field on the Account Object.
    public static void createContactAccodingToNumberOfLocation(List<Account> accList, Map<Id, Account> accOldMap){
        
        // Map<Id, Decimal> accnewMap = new Map<Id, Decimal>();
        Set<Id> accIds = new Set<Id>();
        // List to hold contacts to be inserted
        List<Contact> conList = new List<Contact>();
        
        for(Account acc : accList){
            // Check if the NumberofLocations__c field has changed and is greater than zero
            if (acc.NumberofLocations__c != accOldMap.get(acc.Id).NumberofLocations__c && acc.NumberofLocations__c > 0) {
                //accnewMap.put(acc.Id, acc.NumberofLocations__c);
                accIds.add(acc.Id);
            }
        }
        // Create contacts for each account
        for(Account acc : [Select Id,NumberofLocations__c from Account where Id IN:accIds]){  // OR accnewMap.keySet()
            Decimal numberOfContactsToCreate  = acc.NumberofLocations__c;  // Imp Step
            for(Integer i = 0 ; i < numberOfContactsToCreate; i++){
                Contact con = new Contact();
                con.FirstName = 'Test';
                con.LastName = 'Con' + i;
                con.AccountId = acc.Id;
                conList.add(con);
            }
        }
        // Insert the new contacts
        if(!conList.isEmpty()){
            insert conList;
        }
    }
    
    // Trigger Scenario 8 :The following Trigger will fires when we try to create the account with 
    // same name i.e. Preventing the users to create Duplicate Accounts
    public static void preventDuplicationOfAccountName(List<Account> accList, Map<Id, Account> accOldMap){
        
        Set<String> accNameSet = new Set<String>();
        Set<String> duplicateAccNameSet = new Set<String>();
        //fatch all unique account and add into set
        for(Account acc : accList){
            if(acc.Name !=  accOldMap.get(acc.Id).Name && acc.Name != null){
                accNameSet.add(acc.Name);
            }
        }
        // work on unique account to check same name
        for(Account acc : [Select Id, Name from Account where Id IN: accNameSet]){
            duplicateAccNameSet.add(acc.Name);        
        }
        // check duplicate name and throw error
        for(Account acc : accList){
            if(duplicateAccNameSet.contains(acc.Name)){
                acc.addError('Duplicate Account exists!');
            }
        }
    }
    // 4.Whenever phone field is updated in account then the name field should also get updated with name and phone number in accounts
    public static void updateNameFieldOfAccountRecord(List<Account> accList, Map<Id, Account> accOldMap){
        
        for(Account acc : accList){
            if(acc.Phone !=accOldMap.get(acc.Id).Phone){
                acc.Name = acc.Name + acc.Phone;
            }
        }
    }
    
    // 5.Prevent account from deleting, if it has 2 or more contacts
    
    public static void peventDeletionOfAcc(List<Account> accList){
        Set<Id> accIds = new Set<Id>();
        // Extract Account Ids from the list of Accounts
        for(Account acc : accList){
            if(acc.Id != null){
                accIds.add(acc.Id);
            }
        }
        // Query for Accounts with 2 or more Contacts
        for(Account acc : [Select Id, Name, (Select Id, AccountId from Contacts) from Account where Id IN: accIds]){
            if(acc.Contacts.size() >= 2){
                acc.addError('Cannot delete Account with 2 or more Contacts.');
            }
        }
    }
    
    // 7.Write a trigger to update a field (city) in Account when same field(city) is updated in opportunity
    public static void updateCityFieldOfAccount(List<Account> accList, Map<Id, Account> accOldMap){
        
        //Set<Id>accIds = new Set<Id>();
        //Map<Id, Account> accMap = new Map<Id, Account>();
        Map<Id, String> accMap = new Map<Id, String>();
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        for(Account acc : accList){
            if(acc.City__c != accOldMap.get(acc.Id).City__c){
                //accIds.add(acc.Id);
                //accMap.put(acc.Id, acc);
                accMap.put(acc.Id, acc.City__c);
            }
        }
        
        for(Opportunity opp : [Select Id, AccountId, City__c from Opportunity where AccountId IN: accMap.keySet()]){   // OR accIds
            if(accMap.containsKey(opp.AccountId)){  // OR accIds.contains(opp.AccountId)
                opp.City__c = accMap.get(opp.AccountId); // accMap.get(opp.AccountId).City__c if you user first Map i.e. Map<Id, Account> accMap = new Map<Id, Account>();
                oppList.add(opp);
            }
        }   
        update oppList;
    } 
    // 10. Divide individual balance equally on contacts based on the total balance on related accounts whenever account is updated
    public static void updateIndividualBanalnce(List<Account> accList, Map<Id, Account> accOldMap){
        List<Contact> conList = new List<Contact>();
        Map<Id, Account> accMap = new Map<Id, Account>();
        
        for(Account acc : accList){
            if(acc.Balance__c != null || acc.Balance__c != accOldMap.get(acc.Id).Balance__c){
                accMap.put(acc.Id, acc);
            }
        }
        
        for(Account acc: [Select Id, Name, Balance__c,(Select Id, AccountId, LastName, IndividualBalance__c from Contacts) 
                          from Account where Id IN: accMap.keySet()]){
                              
                              Decimal storeAmount = acc.Balance__c/acc.Contacts.size();   // very very important step
                              for(Contact con : acc.Contacts){
                                  con.IndividualBalance__c  = storeAmount; 
                                  conList.add(con);
                              }
                              
                          }
        if(!conList.isEmpty()){ 
            update conList;
        }
        
    }
    
    // 11. Whenever new account is created with annual revenue more than 50,000 
    // then add Smriti Sharan as contact name
    public static void updateContactNametoSmriti(List<Account> accList){
        
        List<Contact> conList = new List<Contact>();
        
        for(Account acc : accList){
            if(acc.AnnualRevenue >= 50000){
                Contact con = new Contact();
                con.FirstName = 'Smriti';
                con.lastName ='Sharan';
                con.AccountId =  acc.Id;
                conList.add(con);
            }
        }
        insert conList;
    }
    // 15. Whenever account phone is modified then update contact record with 
    // phone field (otherphone with oldvalue and homephone with new value) associated with account records.
    public static void updateContactOtherandHomePhone(List<Account> accList, Map<Id, Account> accOldMap){
        List<Contact> conList = new List<Contact>();
        // Map<Id, Account> accMap = new Map<Id, Account>();
        Set<Id> accIds = new Set<Id>();
        
        for(Account acc : accList){
            if(acc.Phone != accOldMap.get(acc.Id).Phone){
                //accMap.put(acc.Id, acc);
                accIds.add(acc.Id);
            }
        }
        
        for(Account acc : [Select Id, Phone,(Select Id, AccountId, HomePhone, OtherPhone from Contacts) from Account where Id IN: accIds]){  //OR accMap.keySet()
            if(accIds.contains(acc.Id)){  // OR accMap.containsKey(acc.Id)
                for(Contact con : acc.Contacts){
                    con.OtherPhone = accOldMap.get(acc.Id).Phone;   // old Account Phone
                    con.HomePhone =  acc.Phone; //accMap.get(acc.Id).Phone;   new Account Phone
                    conList.add(con);
                }
            }
        }
        if(!conList.isEmpty()){
            update conList;
        }
    }
    // 18.When a new Account record is inserted verify the industry field value, if industry field value is Education then assign the owner as Smriti 
    public static void assignOwnerAsSmriti(List<Account> accList){
        User u = [Select Id from User Where username = 'smriti@sfdc.com'];
        for(Account acc : accList){
            if(acc.Industry == 'Education'){
                acc.OwnerId = u.Id;
            }
        }
    }
    // 19.The trigger will prevent the users from deleting the Accounts.
    //  This is because System Administrator has all the permissions, we cannot change the permissions.
    public static void prevetDeleteOfAccountOtherThanAdmin(List<Account> accList){
        User u =[Select Id, Name from User where Name = 'System Administrator'];
        for(Account acc : accList){
            if(acc.Name == 'System Administrator' && UserInfo.getuserId() != u.Id){
                acc.addError('You Cannot Delete the Account Record');
            }
        }
    }
    
    public static void createdRelatedCon(List<Account> accList){
        List<Contact> conList = new List<Contact>();
        for(Account acc : accList){
            Contact con = new Contact();
            con.LastName = acc.Name;
            con.AccountId = acc.Id;
            conList.add(con);
        }
        if(!conList.isEmpty()){
            insert conList;
        } 
    }
    // a. : If the Account phone number field has been updated, populate the
    // description field of the same Account with previous and new phone nos.
    public static void populateDescription(List<Account> accList, Map<Id, Account> accOldMap){
        
        for(Account acc : accList){
            if(acc.Phone != null && accOldMap != null && acc.Phone != accOldMap.get(acc.Id).Phone){
                acc.Description = 'Previous Phone number: ' + accOldMap.get(acc.Id).Phone + 'new Phone number: ' + acc.Phone;
            }
        }
    }
    
    // Important b: If industry and rating has been updated in an Account 
    // send email to account owner with change details including old and new industry and rating
    
    public static void sendEmailToOwner(List<Account> accList, Map<Id, Account> accOldMap){
        Set<Id> accIds = new Set<Id>();
        
        //if industry and rating has been updated send email to acc owner with change details
        for(Account acc : accList){
            if(acc.Industry != accOldMap.get(acc.Id).Industry && acc.Rating != accOldMap.get(acc.Id).Rating && accOldMap != null){
                accIds.add(acc.Id);
            }
        }
        //if owner id set is not empty method to create and send email to all owners for each
        //of their individual accounts with details about the change in the rating and industry of Account
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Account acc : [Select Id, Name, Rating, Industry, OwnerId from Account where OwnerId IN: accIds]){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            email.setToAddresses(new List<String> {acc.OwnerId});
            email.setSubject('Your Account Industry and Rating is Updated');
            email.setPlainTextBody('Alert! The Rating and Industry of Account : ' + acc.Name +
                                   'Has been change from Old Rating '+ accOldMap.get(acc.Id).Rating + 'To new Rating ' + acc.Rating
                                   + 'And Old Industry ' +  accOldMap.get(acc.Id).Industry + 'to new Industry: ' + acc.Industry);
            emailList.add(email); 
        }
        Messaging.sendEmail(emailList, false);
    }
    
    //c. : Duplicate check to prevent new Account creation if new Nameis same as existing Name
    
    public static void preventDuplicationOfAccount(List<Account> accList){
        Set<String> accNameSet = new Set<String>();
        Set<String> accnewNameSet = new Set<String>();
        for(Account acc: accList){
            if(acc.Name != null){
                accNameSet.add(acc.Id);
            }
        }
        
        for(Account acc : [Select Id, Name from Account where Id IN: accNameSet]){
            if(accNameSet.contains(acc.Id)){
                accnewNameSet.add(acc.Id);
            }
        }
        
        for(Account acc : accList){
            if(accnewNameSet.contains(acc.Id) && acc.Name != null){
                acc.addError('Duplicate Account exists!');
            }
        }  
    }
    // d. : Prevent delete of an account with more than 2 opportunities 
    //and opportunities having amount greater than 4000
    public static void preventDelwithOppAmount(List<Account> accList){
        // Collecting Account Ids being deleted
        Set<Id> accIds = new Set<Id>();
        for(Account acc : accList){
            accIds.add(acc.Id);
        }
        // Querying for Opportunities related to the Accounts being deleted
        Map<Id, Decimal> opportunityCountMap  = new Map<Id, Decimal>();
        for(Opportunity opp: [Select Id, Name, AccountId, Amount from Opportunity where AccountId IN: accIds AND Amount > 4000]){
            opportunityCountMap.put(opp.Id, opp.Amount);
        }
        // Checking for Accounts with more than 2 opportunities with amounts greater than 4000
        
        for(Account acc : accList){
            if(opportunityCountMap.containsKey(acc.Id) && opportunityCountMap.get(acc.Id) >2){
                acc.addError('Cannot delete this account. It has more than 2 opportunities with amounts greater than 4000.');
            }
        }
    }
    //e. Whenever Account name is changed it’s related Contact Last name should be updated to the new account name
    public static void changeRelatedConName(List<Account> accList, Map<Id, Account> accOldMap){
        List<Contact> conList = new List<Contact>();
        //Map<Id, Account> accMap = new Map<Id, Account>();
        Set<Id> accIds = new Set<Id>();
        for(Account acc : accList){
            if(acc.Name != accOldMap.get(acc.Id).Name){
                //accMap.put(acc.Id, acc);
                accIds.add(acc.Id);
            }
        }
        
        /* for(Contact con : [Select Id, AccountId, lastName from Contact where AccountId IN : accMap.keySet()]){
con.LastName = accMap.get(con.AccountId).Name + ' '+ con.LastName;
conList.add(con);
}   */
        for(Account acc: [Select Id, Name,(Select Id, AccountId, LastName from Contacts) from Account where Id IN: accIds]){
            if(accIds.contains(acc.Id)){
                for(Contact con : acc.Contacts){
                    con.LastName = acc.Name + ' ' + con.LastName;
                    conList.add(con);
                }
            }
        }
        update conList;
    }
    //f.  After new account creation create 3 new contacts associate them with the new account,
    // and contact name should be: AccName+CurrentDateTime+unique serial number
    public static void create3associateConts(List<Account> accList){
        List<Contact> conList = new List<Contact>();
        
        for(Account acc : accList){
            // Create 3 contacts for each new account
            for(Integer i = 1; i<= 3; i++){
                Contact con = new Contact();
                con.lastName = acc.Name + '' + DateTime.now().format('yyyyMMdd')+ '' +  i;
                con.AccountId = acc.Id;
                conList.add(con);
            }
        }
        insert conList;
    }
    
}