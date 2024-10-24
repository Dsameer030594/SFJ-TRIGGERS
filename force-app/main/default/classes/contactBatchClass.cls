public class contactBatchClass implements Database.Batchable<SObject>, Database.Stateful {

    // Start Method
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([Select Id from Contact]);
    }
    
     // Execute Method
    public void execute(Database.BatchableContext bc, List<Contact> conList){
        for(Contact con : conList){
            con.Status__c = 'Active';
        }
        update conList;
    }
    
    // finish Method
    public void finish(Database.BatchableContext bc){
        System.debug('Contact Status updated Successfully');
}
}