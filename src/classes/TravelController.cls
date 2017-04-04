public without sharing class TravelController {

    public List<Attachment> attachments = new List<Attachment>();
    Publish_Travel_Guide__c[] queryParentObject = null;
    public boolean flag;
        
     public List<SelectOption> citiesLst {set;}
     public List<SelectOption> costLst {set;}
     public Set<SelectOption> daysLst {set;}
    
     public List<Package__c> existingPkgLst {get;set;}
    
    public List<Package__c> pkgList {get;set;}
    
    public List<Package__c> checkedPackages {get;set;}

     public String selectedCity{get;set;}
     public String selectedCost {get;set;}
     public String selectedDays {get;set;}

    public List<PackageWrapper> pkgWrapperList {get; set;}
    
    public String selectedIds{get;set;}
    
     public String firstName

    { get; set; }
    
    public String lastName

    { get; set; }
    
    public String company

    { get; set; }
    
    public String email

    { get; set; }
    
    public String phone

    { get; set; }   

    
    
    //Constructor
    public TravelController() {
        flag = false;

    }

    public TravelController(ApexPages.StandardController stdController) {

    }
//Getting the attachment data for Travel guide tab.
public List<Attachment> getAttachments() {
    if(attachments.size()==0){
        queryParentObject = Database.query('SELECT Id, Name, (SELECT Id, Name FROM Attachments) FROM Publish_Travel_Guide__c');
       
           for (Publish_Travel_Guide__c parentRecord : queryParentObject){   
              Attachment[] childRecordsFromParent = parentRecord.getSObjects('Attachments');
              if (childRecordsFromParent != null) {
                for (Attachment childRecord : childRecordsFromParent){
                  Object ChildFieldValue1 = childRecord.get('Id');
                  Object ChildFieldValue2 = childRecord.get('Name');         
                 attachments.add(childRecord);
                }    
         
              } 
            }
          }
         return attachments;
      }
// Get the List of cities data from Holiday package object.

     public List<SelectOption> getCitiesLst() {
             List<SelectOption> citiesLst = new List<SelectOption>();
         
            citiesLst .add(new SelectOption('City','All Cities'));
        List<AggregateResult> cityList=[select City__c  from Package__c group by City__c  ];
        for(AggregateResult city:cityList){
              citiesLst .add(new SelectOption(String.valueOf(city.get('City__c')),String.valueOf(city.get('City__c'))));
           }
        return citiesLst ;
        }
        
   // Get the List of number of days from  from Holiday package object.   
  public List<SelectOption> getDaysLst() {
             existingPkgLst=new List<Package__c>();
             List<SelectOption>  daysLst = new List<SelectOption>();
             Set<String> days = new Set<String>();
            daysLst.add(new SelectOption('Days','All Days'));
       List<Package__c> existingPkgLst=[select  No_Of_Days__c   from Package__c   ];
        for(Package__c dayPackage:existingPkgLst){
              //daysLst .add(new SelectOption(String.valueOf(dayPackage.No_Of_Days__c),String.valueOf(dayPackage.No_Of_Days__c)));
              days.add(dayPackage.No_Of_Days__c+'');
          }
          
          for(String day:days){
              daysLst.add(new SelectOption(day,day));
          }
        return daysLst ;
       } 
   
      //Defining the cost ranges  
    public List<SelectOption> getCostLst () {
          List<SelectOption> costLst= new List<SelectOption>();
            costLst.add(new SelectOption('Cost Range','All Prices'));
             
        costLst.add(new SelectOption('Less 2k','<2000'));

        costLst.add(new SelectOption('Between 2k 5k','2000-5000'));

        costLst.add(new SelectOption('Greater 5k','>5000'));
            return costLst;
    }
    
    public List<PackageWrapper> getPkgWrapperList(){
        PageReference x= fetchPackages();
        return pkgWrapperList;
    }
    public PageReference  fetchPackages(){
        flag = true;
        pkgWrapperList = new List<PackageWrapper>();
       
        String city= selectedCity;
        String days = selectedDays;
        String range = '';
        String status = 'Approved';  
         
         String query = 'SELECT Id,Name,No_of_Days__c,City__c,Cost__c    FROM Package__c  where Approval_Status__c=:status';
       	 System.debug('The selected Values are Selected City :'+selectedCity+', Selected Days : '+selectedDays+'status : '+status+' selectedCost : '+selectedCost);
         if(!selectedCost.equals('Cost Range')){
         if(selectedCost.equals('Greater 5k')){           

            range = ' AND cost__c > 5000';
        } else if (selectedCost.equals('Less 2k')){
            range = ' AND cost__c < 2000';
        } else {
            range = ' AND cost__c >= 2000 AND cost__c <= 5000';
        }
         }
         query= query+range;
       
         if(!city.equals('City')){
            query = query+' AND City__c = :city';
         }
          
        
        if(!days.equals('Days')){
            Integer dayCount=integer.valueOf(days);
            query = query+' AND No_Of_Days__c= :dayCount';
         }

        System.debug('Query ------> '+query);
        pkgList = Database.query(query);
        System.debug('Package > '+pkgList);
       for(Package__c pack:  pkgList){
           pkgWrapperList.add(new PackageWrapper(pack));
        
         }
       System.debug('Package > '+pkgWrapperList);
        //return pkgList;
        return null;
    }

    public PageReference back(){  
     
      PageReference pageRef = new PageReference('/apex/PER_Travel_Portal');
        pageRef.setRedirect(true);
         return pageRef;
     }
    
    
    public void processSelected(){
    
      }
    
   
    
    public PageReference submit(){
        return null;
     }
    
    public PageReference loadLeadForm() {
        
        System.debug('InLead Form Method '+pkgWrapperList);
        
         if(pkgWrapperList==null || pkgWrapperList.isEmpty()){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Please get the Holiday Packages you are Interested');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        
        
        checkedPackages=new List<Package__c>();
      
     
      for(PackageWrapper packWrapper:pkgWrapperList){
          System.debug('Package Selected '+packWrapper.isSelected);
           if(packWrapper.isSelected==true){
            System.debug('Checked Package is True  ----> '+packWrapper.pack.Id);
           checkedPackages.add(packWrapper.pack);
           selectedIds += packWrapper.pack.Name+';';

           }
           
         }
        System.debug('Size of Checked Packages  ----> '+checkedPackages.size());
          if(checkedPackages.isEmpty()) {         
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select the Holiday Packages you are Interested');
            ApexPages.addMessage(myMsg);
          return null;
        }   
        
        
        PageReference leadPage = new PageReference('/apex/Lead_Form');
        
        leadPage .getParameters().put('checkedPackages', selectedIds );
         leadPage.setRedirect(false);   
        return leadPage ;

      
    }
      
      
    public PageReference submitForm(){
        if(firstName == '' || firstName == null){
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter First name'));
            return null;
            }

        if(lastName == '' || lastName == null){
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter last Name'));  
            return null;
            }

        if(email == '' || email == null){
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter email'));
            return null;
            }

        if(phone == '' || phone== null){
       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter phone'));
           // return null;
            }


         
      
          PageReference pageRef = new PageReference('/apex/Last_Page');
          pageRef.setRedirect(true);
          return pageRef;
     }
}