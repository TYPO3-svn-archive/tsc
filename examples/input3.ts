
// We expect errors for 'fünf', 'zwölf', 'fünfzehn' due to invalid umlauts in keys,
// While they are valid as value. 


value = in level 0
level1{
 value = in level 1
  level2 {
    value = in level 2
    level3 {
      value = in level 3
      level4 {
        value = in level 4 
      }
      anotherLevel4 {
        value = in another level 4 
      }
      anotherValue = another value in level 3
    }
    anotherValue = another value in level 2
  }
  antherValue = another value in level 1
}
antherValue = another value in level 0

