# Serialization

## General

The XML serialization engine used in the Open Systems Pharmacology Project can be found in the [OSPSuite.Serializer solution](https://github.com/Open-Systems-Pharmacology/OSPSuite.Serializer). 

## Writing a serilizer for a new class

When writing a serializer for a new class 'NewClass' you have to write a 'NewClassSerializer : OSPSuiteXmlSerializer<NewClass>'. 
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
