public class PackageWrapper { 

     
      public boolean isSelected{get;set;}
      public Package__c pack {get; set;} 
      
      public PackageWrapper(Package__c pack){
          this.pack=pack;
          this.isSelected = false;
          
      }
    
     
    
}