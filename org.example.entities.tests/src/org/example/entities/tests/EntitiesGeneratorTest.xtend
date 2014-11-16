package org.example.entities.tests

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.xbase.compiler.CompilationTestHelper
import org.eclipse.xtext.xbase.lib.util.ReflectExtensions
import org.example.entities.EntitiesInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith
import static extension org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EntitiesInjectorProvider))
class EntitiesGeneratorTest {
	@Inject extension CompilationTestHelper
	@Inject extension ReflectExtensions

	@Test
	def void testGeneratedCode() {
		'''
entity MyEntity {
string myAttribute;
}
'''.assertCompilesTo(
			'''package entities; 
public class MyEntity {
	private String myAttribute;
	
	public String getMyAttribute(){
		return myAttribute;
	}
	
	public void setMyAttribute(String _arg){
		this.myAttribute=_arg;
	}
	
}
			''')
	}

	@Test
	def void testGeneratedValidJavaCode() {

		'''
entity MyEntity {
string myAttribute;
}
'''.compile [
			getCompiledClass.newInstance => [
				assertNull(it.invoke("getMyAttribute"))
				it.invoke("setMyAttribute", "value")
				assertEquals("value", it.invoke("getMyAttribute"))
			]
		];
	}

	@Test
	def void testGeneratedCodeWithTwoEntites() {
		'''
entity FirstEntity {
SecondEntity myAttribute;
}
entity SecondEntity { }
'''.compile [
			'''package entities; 
public class FirstEntity {
	private SecondEntity myAttribute;
	
	public SecondEntity getMyAttribute(){
		return myAttribute;
	}
	
	public void setMyAttribute(SecondEntity _arg){
		this.myAttribute=_arg;
	}
	
}
			'''.
				toString.assertEquals(getGeneratedCode("entities.FirstEntity"))
			'''
package entities; 
public class SecondEntity {
	
}
'''.toString.assertEquals(getGeneratedCode("entities.SecondEntity"))
		]
	}
}
