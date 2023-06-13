## Algorithm for the creation of a new individual

This page describes the algorithm used in OSPSuite to create an individual.

# Nomenclature
* OriginData: The data defining the individual `{species, population, gender, age, weight, height etc... }`
* inputWeight: Weight entered by the user
* inputHeight: Height entered by the user
* inputAge: Age entered by the user
* meanWeight: Default weight for the combo {species, population, gender, age}
* meanHeight : Default height for the combo {species, population, gender, age}
* organ_i.Volume: Volume in organ_i
* hrel: Relative height (ratio between inputHeight und meanHeight)

The goal of the “create individual” algorithm is to create the most probable individual for a
given OriginData. Two cases need to be discussed:

# Species is not age dependent
We do not have age dependent distribution information in our database so far.

## Algorithm
In that case, the algorithm simply scales the volumes with the ratio inputWeight/meanWeight

For each organ organ_i defined in the individual we have

```
organ_i.Volume = organ_i.Volume * inputWeight/meanWeight;
```

such that
```
Sum(organ_i.Volume) = inputWeight
```

# Species is age dependent
More interesting is of course the case of an age dependent species (i.e. age dependent
distributions are available for parameters such as Volume, Hematocrit etc..). There are two
classes of parameters that will be adjusted:
1. Organ volumes (optimized)
1. Other distributed Parameters such as HCT (default value from distribution)

## Algorithm

### STEP 1 
Retrieve all available distributions from the database, for the given
{species, population, gender, age, gestational age} combination:

  1. Distribution Type (normal, lognormal, discrete)
  1. Parameters (Mean und Std for normal and lognormal, value for discrete)

We call these distribution info parameter _MuSigma_

### STEP 2
Scale distribution parameters each organs with the global parameter `hrel` and the organ parameter `allometricScaleFactor` (alpha) according to the following pseudo code:

```
hrel = inputHeight/meanHeight
if(distribution is normal)
  Mean = Mean * hrel^alpha
  Deviation = Deviation * hrel^alpha
else if (distribution is lognormal)
  Mean = Mean + log(hrel^alpha)
end
````

The values used for `allometricScaleFactor` are:

| Organ | allometricScaleFactor|
| --- | --- | 
| VenousBlood | 0,75 |
| Stomach | 0,75 |
| Spleen | 0,75 |
| SmallIntestine | 0,75 |
| Skin | 1,6 |
| PortalVein | 0,75 |
| Pancreas | 0,75 |
| Muscle | 2 |
| Lung | 0,75 |
| Liver | 0,75 |
| LargeIntestine | 0,75 |
| Kidney | 0,75 |
| Heart | 0,75 |
| Gonads | 0,75 |
| Fat | 2 |
| Brain | 0 |
| Bone | 2 |
| ArterialBlood | 0,75 |

### STEP 3
We run an optimization using a Nelder Mead Simplex regression (fminsearch in Matlab). 
What do we optimize and how does that work?

#### 1. Generate a start value

* we generate random volume value based on the new distributions that were
generated above. That means that for each organ, we generate a new volume value according to the following pseudo code, where perturbation is a random number in [0..1]
```
if(distribution is normal)
  Return Mean + Deviation *perturbation
else if (distribution is lognormal)
  Return Mean * exp(Log(Deviation) * perturbation)
 end if
```
* The randomly generated skin volume is then adjusted based on the input weight according to the following formula 
```
Organ_skin.Volume = Organ_skin.Volume * (inputBodyWeight / (meanBodyWeight * hrel^2))^1/2
```
* Finally the fat weight is adjusted to match the target body weight
```
Weight_fat = inputBodyWeight – (Sum_i(weight_i) where i!=fat
```
* The algorithm then calculates the probability of having an individual with the randomly generated volumes and the corresponding bodyweight (currentBodyWeight) using following pseudo code:
```
skinFactor = (currentBodyWeight / (meanBodyWeight * hrel^2))^1/2
for each organ
  if(organ is skin)
    mean_skin = mean_skin * skinFactor;
    deviation_skin = deviation_skin * skinFactor; 
  end if
  props[i] = MuSigma_organ.ProbabilityFor(organ.Volume);
end

double p = 1;
for (int i = 0; i < props.Count(); i++)
  p= p * props[i];
end

return p
```
If the calculated probability p is 0, we go back to generating another start value. The algorithm tries to generate
up to 100 start values with the given `{Age, Gestational Age, Weight, Height}` parameters. If no probable start value can be found, the algorithm throws the `UnableToCreateIndividualWithConstraintsException` exception


#### 2. Start optimization
Granted that the algorithm was able to find a start value, we now start to optimize the volumes so that the probability of having an individual with the given volumes is maximized.

**Note:** Fat volume is not optimized as the value is our compensator parameter allowing us to land on the target input weight.