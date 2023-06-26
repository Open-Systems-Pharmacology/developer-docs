# Serialization

## General

The XML serialization engine used in the Open Systems Pharmacology Project can be found in the [OSPSuite.Serializer solution](https://github.com/Open-Systems-Pharmacology/OSPSuite.Serializer). The way the xml mapping works is pretty straightforward, mapping objects to xml elements and keeping the treelike structure where it exists, storing object names and serializing and deserializing according to Ids. This actually makes the xml for a project (a .pkml file for PKSim f.e.) intelligible, and one can even go through the contents of a project. 

'''
  <Simulation id="XMVCOCRQwky6ttpq36MONA" name="Simple">
    <BuildConfiguration>
      <Molecules id="dJRCM06S7UG-ZbT3H6GNAQ" name="Simple" bbVersion="0">
        <Builders>
          <MoleculeBuilder id="jrKhlw58IkeRn6kWO6UYFA" name="C1" icon="Drug" mode="Logical" containerType="Other" isFloating="1" quantityType="Drug" isXenobiotic="1" defaultStartFormula="jjQg_fgKKkOJLrMEuyOC5g">
            <Children>
              <Parameter id="QR9mTPJCvU69y38G4q-big" name="pKa_pH_WS_sol_K7" description="Supporting parameter for calculation of pKa- and pH- dependent solubilty scale factor at refPH" persistable="0" isFixedValue="0" dim="Dimensionless" quantityType="Parameter" formula="CompoundAcidBase_PKSim.PARAM_pKa_pH_WS_sol_K7" buildMode="Property" visible="0" canBeVaried="0" />
              <Parameter id="UliE_UU0c0uWAKtlM8vFqg" name="pKa_pH_WS_sol_F3" description="Supporting parameter for calculation of pKa- and pH- dependent solubilty scale factor at refPH" persistable="0" isFixedValue="0" dim="Dimensionless" quantityType="Parameter" formula="CompoundAcidBase_PKSim.PARAM_pKa_pH_WS_sol_F3" buildMode="Property" visible="0" canBeVaried="0" />
              .
              .
              .
              </Children>
            <UsedCalculationMethods>
              <UsedCalculationMethod category="DistributionCellular" calculationMethod="Cellular partition coefficient method - PK-Sim Standard" />
              .
              .
              .
            </UsedCalculationMethods>
          </MoleculeBuilder>
'''


The only case where things are a bit more complicated is the Formula Cache. If you open the xml segment of the Formula Cache in a .pkml file you will see something like the following:

'''
 <FormulaCache>
          <Formulas>
            <Formula id="nyGiXWaSW0OYhQJ__lyZhg" name="Concentration_formula" dim="Concentration (molar)" formula="M/V">
              <Paths>
                <Path path="0" as="1" dim="2" />
                <Path path="3" as="4" dim="5" />
              </Paths>
            </Formula>
            <Formula id="Jv7-T-BLjEKUKypb2n2YIA" name="PLnL_zu_MFormula" dim="Concentration (molar)" formula="1e15/6.02214179e23" />
            <Formula id="lU8mEpGab0-unqhumPvr6g" name="PLFormula" dim="Concentration (molar)" formula="dilutionFactor*S_PL*PLnL_zu_M">
              <Paths>
                <Path path="6" as="7" />
                <Path path="8" as="9" />
                <Path path="10" as="11" />
              </Paths>
            </Formula>
            .
            .
            .
         </Formulas>
'''
The above excerpt is a simple PK-Sim project, and more specifically the S1_concentrBased.pkml that is part of the test data of PKSim codebase.
As you can see, in the Formula Cache, instead of having the actual formula strings, we have path numbers that refer to the StringMap that follows:

'''
 <StringMap>
            <Map s=".." id="0" />
            <Map s="M" id="1" />
            <Map s="Amount" id="2" />
            <Map s="..|..|Volume" id="3" />
            <Map s="V" id="4" />
            <Map s="Volume" id="5" />
            <Map s="..|PL|dilutionFactor" id="6" />
            <Map s="dilutionFactor" id="7" />
            <Map s="..|PL|S_PL" id="8" />
            <Map s="S_PL" id="9" />
            .
            .
            .
 </StringMap>
'''

This has occurred historically in order to avoid duplication of strings in bigger project files and thus help reduce the project file size. 


## Writing a serializer for a new class

When creating a new class in OSPSuite of an object that will then need to be saved to the project file, a new serializer will also have to be written for that class. Let's call our new class 'NewClass'. If the class gets created in OSPSuite.Core and is not implementing an interface that already has an abstract serializer, the convention would be to write a serializer called 'NewClassSerializer : OSPSuiteXmlSerializer<NewClass>'. 

You will then have to write a an override for the 'PerformMapping()' function, that serializes the properties of the class:

For example:

'''
public class NewClass
{
   public string Name { get; set; }

}
'''

'''
public class NewClassSerializer : OSPSuiteXmlSerializer<NewClass>
{
   public override void PerformMapping()
   {
      Map(x => x.Name);
   }
}
'''

Of if your new class implements an interface that already has an abstract serializer, it is that one that you will need to extend. For example if you are writing a new Building Block class (that would be implementing the interface IBuildingBlock), the serializer signature would be  

'''
public class NewClassSerializer : BuildingBlockXmlSerializer<NewClass>
'''


Now let's talk a bit about the mapping a classes properties in the PerformMapping() override. The most frequent use cases would be:

# Map()

When you want to serialize a property of a class and a serializer already exists for the type of property you want to serialize (as is f.e. for string, int and the other basic types, or in case there is a serializer already written for this object in the solution), you only need to use Map function like in the above example with 'Map(x => x.Name);'. You  do not need to explicitly define what needs to be deserialized or how, the framework will take care of that for you. 

# MapEnumerable()

If the class property that you need to serialize is an IEnumerable (a list, a OSPSuite Cache collection,), and there exists a serializer for the type of objects stored in th IEnumerable, you need to define the serialization of that property with the MapEnumerable() function, where you pass the enumerable and an method used to add objects to the defined IEnumerable. As an example, with an readonly list:

'''
public class NewClass
{
   private readonly List<object> _allData;

   public IReadOnlyList<object> AllData
   {
      get { return _allData; }
   }

   public void Add(object singleData)
   {
      _allData.Add(singleData);
   }
}

.
.
.
public class NewClassSerializer : OSPSuiteXmlSerializer<NewClass>
{
   public override void PerformMapping()
   {
      MapEnumerable(x => x.AllData, x => x.Add);
   }
}

'''

