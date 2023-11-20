# Serialization

## Introduction

In this part of the documentation we will talk about the serialization deserialization of classes and other data to xml. This serialization is used to save and load projects and pkmls.

## General

The XML serialization engine used in the Open Systems Pharmacology Project can be found in the [OSPSuite.Serializer solution](https://github.com/Open-Systems-Pharmacology/OSPSuite.Serializer). The way the xml mapping works is pretty straightforward, mapping objects to xml elements and keeping the treelike structure where it exists, storing object names and serializing and deserializing according to Ids. This actually makes the xml for a project (a .pkml file for PKSim e.g.) intelligible, and one can even go through the contents of a project. 

```
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
```


The only case where things are a bit more complicated is the Formula Cache. If you open the xml segment of the Formula Cache in a .pkml file you will see something like the following:

```
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
```
The above excerpt is a simple simulation created in PK-Sim and exported to pkml, and more specifically the [S1_concentrBased.pkml](https://github.com/Open-Systems-Pharmacology/PK-Sim/blob/develop/tests/PKSim.Tests/Data/S1_concentrBased.pkml) that is part of the test data of PKSim codebase.
As you can see, in the Formula Cache, instead of having the actual formula strings, we have path numbers that refer to the StringMap that follows:

```
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
```

This has occurred historically in order to avoid duplication of strings in bigger project files and thus help reduce the project file size. 

## Xml Attribute Mapping

The functionality of mapping to specific xml attributes is handled by AttributeMappers that are added to the AttributeMapperRepository either in [OSPSuiteXmlSerializerRepository](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/blob/develop/src/OSPSuite.Core/Serialization/Xml/OSPSuiteXmlSerializerRepository.cs) in OSPSuite.Core or in the individual solutions in [PKSimXmlSerializerRepository](https://github.com/Open-Systems-Pharmacology/PK-Sim/blob/develop/src/PKSim.Infrastructure/Serialization/Xml/Serializers/PKSimXmlSerializerRepository.cs) and [MoBiXmlSerializerRepository](https://github.com/Open-Systems-Pharmacology/MoBi/blob/develop/src/MoBi.Presentation/Serialization/Xml/Serializer/MoBiXmlSerializerRepository.cs). This is how for example you can specify for the `Species` in PK-Sim the name gets serialized in the xml and the rest gets saved in the database.

## Project (De)Serialization

Let's talk first for a PK-Sim project. In [ProjectMetaDataToProjectMapper.cs](https://github.com/Open-Systems-Pharmacology/PK-Sim/blob/develop/src/PKSim.Infrastructure/Serialization/ORM/Mappers/ProjectMetaDataToProjectMapper.cs) of the PK-Sim solution the order of (de)serialization is defined. When starting the application e.g. we get the project structure from the database and then we further load the contents from the project file. In MoBi correspondingly the project (de)serialization is also defined in [ProjectMetaDataToProjectMapper.cs](https://github.com/Open-Systems-Pharmacology/MoBi/blob/develop/src/MoBi.Core/Serialization/ORM/Mappers/ProjectMetaDataToProjectMapper.cs) of the MoBi solution. The main difference between the two is that the entities in PK-Sim are lazy loaded, whereas in MoBi we load everything on startup.

## Writing a serializer for a new class

When creating a new class in OSPSuite of an object that will then need to be saved to the project file, a new serializer will also have to be written for that class. Let's call our new class `NewClass`. If the class gets created in OSPSuite.Core and is not implementing an interface that already has an abstract serializer, the convention would be to write a serializer called `NewClassSerializer : OSPSuiteXmlSerializer<NewClass>`. 

You will then have to write a an override for the `PerformMapping()` function, that serializes the properties of the class:

For example:

```
public class NewClass
{
   public string Name { get; set; }

}
```

```
public class NewClassSerializer : OSPSuiteXmlSerializer<NewClass>
{
   public override void PerformMapping()
   {
      Map(x => x.Name);
   }
}
```

In case your new class implements an interface that already has an abstract serializer, it is that one that you will need to extend. For example if you are writing a new Building Block class (that would be implementing the interface IBuildingBlock), the serializer signature would be  

```
public class NewClassSerializer : BuildingBlockXmlSerializer<NewClass>
```


Now let's talk a bit about the mapping a classes properties in the `PerformMapping()` override. The most frequent use cases would be:

# Map(...)

When you want to serialize a property of a class and a serializer already exists for the type of property you want to serialize (as is e.g. for string, int and the other basic types, or in case there is a serializer already written for this object in the solution), you only need to use Map function like in the above example with `Map(x => x.Name);`. You  do not need to explicitly define what needs to be deserialized or how, the framework will take care of that for you. Additionally, you can use the mapping extensions to specify the xml element name to which your property will be mapped by calling `Map(x => x.Name).WithMappingName(mappingName);`, where mappingName is a string.

# MapEnumerable(...)

If the class property that you need to serialize is an IEnumerable (a list, a OSPSuite Cache collection,), and there exists a serializer for the type of objects stored in th IEnumerable, you need to define the serialization of that property with the MapEnumerable() function, where you pass the enumerable and an method used to add objects to the defined IEnumerable. As an example, with an readonly list:

```
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

```

For 90% of the cases when creating a serializer for a new class, the above should be adequate and writing the serializer should be pretty straightforward: just adding the corresponding `Map(...)` and `MapEnumerable(...)` calls for the class properties that need to be serialized to the `PerformMapping(...)` override of the serializer.

# MapReference(...)

Moving now to a more complicated use case: sometimes we have a class that has a reference to another object. Take the class [WeightedObservedData](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/blob/develop/src/OSPSuite.Core/Domain/WeightedObservedData.cs) in OSPSuite.Core for example:

```
   public class WeightedObservedData
   {
      public virtual DataRepository ObservedData { get; }
      .
      .
      .
      public WeightedObservedData(DataRepository observedData)
      {
         ObservedData = observedData;
         .
         .
      }
      .
      .
   }
```

and its [serializer](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/blob/develop/src/OSPSuite.Core/Serialization/Xml/WeightedObservedDataXmlSerializer.cs):

```
   public class WeightedObservedDataXmlSerializer : OSPSuiteXmlSerializer<WeightedObservedData>
   {
      public override void PerformMapping()
      {
         .
         .
         .
         MapReference(x => x.ObservedData);
      }
   }
```

In such a case the `Datarepository` that is `ObservedData` also exists in the Project and gets serialized and deserialized separately. We would not like to keep multiple copies of the same object in our project file, and therefore what we are going to write in the xml is a reference to that `ObservedData`. 
It is important though in this case to keep in mind than when deserializing we have to make sure the `ObservedData`  is available when deserializing the corresponding `WeightedObservedData`, otherwise we might end up with an exception. That would mean that either the `ObservedData` has been (de)serialized before the (de)serialization of `WeightedObservedData` or within the same (de)serialization action (meaning that a `WeightedObservedData` object references an `ObservedData` object and both objects are withing the root note and the action is (de)serializing that common root node).

The observed data of a project is a very good example of this, since they are referenced in many different places of a project. Note for example that if you write a new class that has a `WeightedObservedData` member, when you are serializing it you would also be implicitly keeping a reference to the Observed Data underneath that object - and therefore will have to be careful that the (de)serialization in your project is correct.

# TypedSerialize(...) - TypedDeserialize(...)

In case the above functionalities do not cover your use case, you can also use `TypedSerialize(TObject objectToSerialize, TContext context)` and `TypedDeserialize(TObject objectToDeserialize, XElement outputToDeserialize, TContext context)` to be able to specify the actions that should happen before and after (de)serialization. This is the functionality used e.g. for the (de)serialization of the FormulaCache and its corresponding StringMap (as discussed in the xml structure section above). 

A simple example for the use of these two functions in a class in Core is the [DisplayUnitMapXmlSerializer](https://github.com/Open-Systems-Pharmacology/OSPSuite.Core/blob/develop/src/OSPSuite.Core/Serialization/Xml/DisplayUnitsManagerXmlSerializer.cs). There we have a  `OSPSuite.Core.Domain.UnitSystem.Unit` as DisplayUnit member and we want to serialize the unit name as a string. We also serialize the dimension. When we deserialize we want to get from the created `DisplayUnitMap` dimension the actual Unit and not just a string.

```
   public class DisplayUnitMapXmlSerializer : OSPSuiteXmlSerializer<DisplayUnitMap>
   {
      public override void PerformMapping()
      {
         Map(x => x.Dimension);
      }

      protected override void TypedDeserialize(DisplayUnitMap displayUnitMap, XElement element, SerializationContext serializationContext)
      {
         base.TypedDeserialize(displayUnitMap, element, serializationContext);
         element.UpdateDisplayUnit(displayUnitMap);
      }

      protected override XElement TypedSerialize(DisplayUnitMap displayUnitMap, SerializationContext serializationContext)
      {
         var element = base.TypedSerialize(displayUnitMap, serializationContext);
         return element.AddDisplayUnitFor(displayUnitMap);
      }
   }
```

For that we are also using the following extension methods on the xml element:

```
public static XElement AddDisplayUnitFor(this XElement element, IWithDisplayUnit withDisplayUnit)
{
   return AddDisplayUnit(element, withDisplayUnit.DisplayUnit);
}

public static XElement AddDisplayUnit(this XElement element, Unit unit)
{
   if (unit == null || string.IsNullOrEmpty(unit.Name))
      return element;

   element.AddAttribute(Constants.Serialization.Attribute.DISPLAY_UNIT, unit.Name);
   return element;
}

.
.
.

public static void UpdateDisplayUnit(this XElement element, IWithDisplayUnit withDisplayUnit)
{
   withDisplayUnit.DisplayUnit = GetDisplayUnit(element, withDisplayUnit);
}

public static Unit GetDisplayUnit(this XElement element, IWithDimension withDimension)
{
   return GetDisplayUnit(element, withDimension.Dimension);
}

public static Unit GetDisplayUnit(this XElement element, IDimension dimension)
{
   if (dimension == null)
      return null;

   var displayUnit = element.GetAttribute(Constants.Serialization.Attribute.DISPLAY_UNIT);
   return dimension.UnitOrDefault(displayUnit);
}

```

