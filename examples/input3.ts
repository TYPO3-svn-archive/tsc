
// Here we show how braces trigger levels

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


// setting multiple levels by dots

value1 = in base 
levelA.levelB {
	value1 = in level B
	levelC.levelD {
		value1 = in level D
	}
	value2 = back in level B
}
value2 = back in base 
