public class OpportunityTriggerHandler {
    
    // Trigger Scenario 6, 16: Whenever Opportunity "Stage" is modified to "Closed Won" 
    // then set "Close Date" as "Today Date" and "Type" as "New Customer".
    public static void setCloseDateandType(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        for(Opportunity opp : oppList){
            if(opp.StageName != oppOldMap.get(opp.Id).StageName && oppOldMap != null && opp.StageName == 'Closed Won'){
                opp.CloseDate = System.today();
                opp.Type = 'New Customer';               
            }
        }  
    }
    
    // 3. Update Account Rating to Hot on account when opportunity is inserted or updated and stage equals to 'closed Won'.
    
    public static void updateAccountRatingToHot(List<opportunity> oppList, Map<Id, opportunity> oppOldMap){
        
         Map<Id, opportunity> oppMap = new Map<Id, opportunity>();
       // Set<Id> accIds = new Set<Id>();
        List<Account> accList = new List<Account>();
        for(Opportunity opp : oppList){
            if((opp.StageName != null && opp.StageName == 'Closed Won') // for insert
               ||(oppOldMap != null && opp.StageName != oppOldMap.get(opp.Id).StageName && opp.StageName == 'Closed Won')){  // for update
                    oppMap.put(opp.Id, opp);
                   //accIds.add(opp.AccountId);
               }
        }
        
        for(Account acc : [Select Id, Name, Rating,(Select Id, AccountId, StageName from Opportunities) from Account where Id IN: oppMap.keySet()]){   //oppMap.keySet() OR accIds
            if(oppMap.containsKey(acc.Id)){   // if(oppMap.containsKey(acc.Id))  OR accIds.contains(acc.Id)
                acc.Rating = 'Hot'; 
                accList.add(acc);
            } 
        }
        // Perform bulk update
        update accList;  
    }
    // 8.Whenever TestPhoneOpportunity__c field in opportunity is updated,
    // its related field (TestPhoneAccount__c) in Account and 
    // (TestPhoneContact__c ) in Contact should get updated with the updated value with TestPhoneOpportunity__c
    public static void updaterelatedAccNadConField(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        
        Map<Id, Opportunity> oppNewMap = new Map<Id,Opportunity>();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        
        for(Opportunity opp : oppList){
            if(opp.TestPhoneOpportunity__c != oppOldMap.get(opp.Id).TestPhoneOpportunity__c){
                oppNewMap.put(opp.AccountId, opp);
            }
        }
        // Updating related Account and Contact records
        if(!oppNewMap.isEmpty()){
            // Querying related Account and Contact records
            // Account is Parent for Opportunity (From Opp to Acc create Child to Parent SOQL)
            // But Contact is child for Opportunity (From Parent to child create SOQL)
            for(Account acc : [Select Id, Name, TestPhoneAccount__c,(Select Id, AccountId, TestPhoneContact__c from Contacts) from Account Where Id IN: oppNewMap.keySet()]){
                if(oppNewMap.containsKey(acc.Id)){
                    acc.TestPhoneAccount__c = oppNewMap.get(acc.Id).TestPhoneOpportunity__c; 
                    accList.add(acc);
                }
                for(Contact con : acc.Contacts){
                    con.TestPhoneContact__c = oppNewMap.get(con.AccountId).TestPhoneOpportunity__c;  
                    conList.add(con);
                }
            }
        }
        // Performing updates
            if (!accList.isEmpty()) {
                update accList;
            }
            if (!conList.isEmpty()) {
                update conList;
            }
    }
    //9.When an opportunity is inserted or updated then if the stage name is 'Closed won' then add the task.
    public static void createRelatedTask(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        List<Task> taskList = new List<Task>();
        
        for(Opportunity opp : oppList){
            if(opp.StageName != oppOldMap.get(opp.Id).StageName && opp.StageName == 'Closed Won' && oppOldMap != null){
                Task tk = new Task();
                tk.Subject = 'Follow Up Test Task';
                tk.Status = 'Not Started';
                tk.Priority = 'Normal';
                tk.WhatId = opp.Id;
                taskList.add(tk);
            }
        }
        if(taskList.size() > 0){
            insert taskList;
        }
    }
    //a. : Roll up total number of opportunities under each account after Opportunity is created, deleted or undeleted    
    public static void rolupNoOfOppOnAccount(List<Opportunity> oppList){
        List<Account> accList = new List<Account>();
        Set<Id> accIds = new Set<Id>();
        
        for(Opportunity opp : oppList){
            if(opp.AccountId != null && oppList != null){
                accIds.add(opp.AccountId);
            }
        }
        
        for(Account acc : [Select Id, Name, Total_Opportunity_Count__c,(Select Id, AccountId, Name from Opportunities)FROM Account where Id IN: accIds ]){
            if(accIds.contains(acc.Id)){
                acc.Total_Opportunity_Count__c =acc.Opportunities.size();
                accList.add(acc);
            }  
        }
        update accList;
    }
    // b. : Roll up count of High Valued opportunities under parent account for 
    // each opportunity with amount>5000 and Stage='Closed Won' when Opportunity is created, deleted or 
    // undeleted and when the Opportunity is updated and amount changes and amount >5000 and Stage changes to 'Closed Won'
    public static void rollupHighValueOppONAccount(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        
        //Account Ids set to hold unique parent account for each opportunity
        Set<Id> accIds=new Set<Id>();
        List<Account> accList = new List<Account>();
        
        // Determine which Accounts need to be updated
        for(Opportunity opp : oppList){
            if(opp.AccountId != null && opp.Amount > 5000 && opp.StageName == 'Closed Won' && opp.Amount != oppOldMap.get(opp.Id).Amount && opp.StageName != oppOldMap.get(opp.Id).StageName){
                accIds.add(opp.AccountId);
            }
        }
        // Query Accounts and their Opportunities meeting the criteria
        for(Account acc :[Select Id, Name, High_Value_Opportunities__c,(Select Id, AccountId, Amount, StageName 
                                                                        from Opportunities WHERE Amount > 5000 AND StageName = 'Closed Won')
                          from Account where Id IN: accIds]){
                              // Update the High_Value_Opportunities__c field for each Account
                              if(accIds.contains(acc.Id)){
                                  acc.High_Value_Opportunities__c = acc.Opportunities.size();
                                  accList.add(acc);
                              }
                              update accList;
                          }      
    }
    // c.: Roll up sum of amount of each opportunity with StageName=='Negotiation/Review' under parent account after
    //insert, delete or undelete and when the Opportunity is updated and amount is not empty and amount changes and Stage
    //changes to 'Negotiation/Review' OR Stage is 'Negotiation/Review' and amount changes but is not 0 or null or negative
    
    public static void rollupSumOfOppAmountBasedOnStage(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        
        // Set to hold unique account IDs for opportunities to be processed
        Set<Id> accIds = new Set<Id>();
        List<Account> accList = new List<Account>();
        
        // Determine which Accounts need to be updated
        for(Opportunity opp : oppList){
            if((opp.AccountId != null && opp.Amount != null && opp.StageName == 'Negotiation/Review' && oppOldMap == null) || 
               (oppOldMap != null && opp.Amount != null && opp.Amount != oppOldMap.get(opp.Id).Amount && opp.Amount > 0 
                && opp.StageName == 'Negotiation/Review' && opp.StageName != oppOldMap.get(opp.Id).StageName)){
                    
                    accIds.add(opp.AccountId);   
                }
            // Query Accounts and their Opportunities meeting the criteria
            // Update the rollUpAmount_with_Stage_is_Negotation__c field for each Account
            for(Account acc : [Select Id, Name, rollUpAmount_with_Stage_is_Negotation__c, 
                               (Select Id, AccountId, Amount, StageName from Opportunities where Amount >0 AND StageName = 'Negotiation/Review')from Account where Id IN: accIds]){
                                   Decimal totalAmount = 0;
                                   for (Opportunity opps : acc.Opportunities) {
                                       totalAmount += opps.Amount;
                                   }
                                   acc.rollUpAmount_with_Stage_is_Negotation__c = totalAmount;    
                               }          
            // Update Accounts
            if (!accList.isEmpty()) {
                update accList;
            }         
        }   
    }  
}