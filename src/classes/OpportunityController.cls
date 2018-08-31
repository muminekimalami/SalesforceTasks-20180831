public with sharing class OpportunityController {
    
    private final Opportunity opportunity;
    private ApexPages.StandardController controller;
    public String selectedDV {get; set;}
    public String selectedPB {get; set;}
    
    public OpportunityController(ApexPages.StandardController stdController) {
        this.opportunity = (Opportunity)stdController.getRecord();
        this.controller = stdController;
    }
    
    //rendering divisions from 01 to 03
    public List<Selectoption> getDivisions() {
        List<Selectoption> divisions = new List<Selectoption>();
        divisions.add(new Selectoption('00_','--Select Division--'));
        divisions.add(new Selectoption('01_','01'));
        divisions.add(new Selectoption('02_','02'));
        divisions.add(new Selectoption('03_','03'));
        
        return divisions; 
    }
    
    //rendering Pricebooks depending on what is chosen in divisions.
    public List<Selectoption> getPricebooks () {
        List<Selectoption> pricebooks;
        if (selectedDV != '00_') {
            pricebooks = new List<Selectoption>();
            for (Pricebook2 p : [SELECT Name FROM Pricebook2 WHERE Name like :selectedDV + '%']) {
                String name = p.Name.replace(selectedDV, '');
                pricebooks.add(new Selectoption(p.Id, name));
            }
        } else {
            pricebooks = new List<Selectoption>();
            pricebooks.add(new SelectOption('err', '--Firstly, select a division--'));
        }
        return pricebooks;
    }
    
    public PageReference mySave () {
        if (selectedDV == '00_' && selectedPB == 'err') {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Select Division before saving!');
            ApexPages.addMessage(myMsg); 
        }else {
            try {
                opportunity.Pricebook2Id = selectedPB;
                return controller.save();    
            }catch (System.DMLException e) {
                ApexPages.addMessages(e);
            }catch (NullPointerException ex) {
                ApexPages.addMessages(ex);
            }            
        }
        return null;
    }
    
    
}