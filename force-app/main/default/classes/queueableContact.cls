public class queueableContact implements Queueable {

    public void execute(QueueableContext qc){
        List<Contact> conList = [Select Id, Status__c from Contact];
   
        for(Contact con : conList){
            con.Status__c = 'InActive';
        }
        update conList;
    }  
    }