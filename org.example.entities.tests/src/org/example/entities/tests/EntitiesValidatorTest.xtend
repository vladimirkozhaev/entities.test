package org.example.entities.tests

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.example.entities.EntitiesInjectorProvider
import org.example.entities.entities.EntitiesPackage
import org.example.entities.entities.Model
import org.example.entities.validation.EntitiesValidator
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(EntitiesInjectorProvider))
class EntitiesValidatorTest {
	@Inject extension ParseHelper<Model>
	@Inject extension ValidationTestHelper

	@Test
	def void testEntityExtendsItself() {
		'''
entity MyEntity extends MyEntity {
}
'''.parse.assertError(
			EntitiesPackage::eINSTANCE.entity,
			EntitiesValidator::HIERARCHY_CYCLE,
			"cycle in hierarchy of entity 'MyEntity'"
		)
	}

	@Test
	def void testCycleInEntityHierarchy() {
		val model = '''
entity A extends B {}
entity B extends C {}
entity C extends A {}
'''.parse

		model.assertError(
			EntitiesPackage::eINSTANCE.entity,
			EntitiesValidator::HIERARCHY_CYCLE,
			"cycle in hierarchy of entity 'A'"
		)

		model.assertError(
			EntitiesPackage::eINSTANCE.entity,
			EntitiesValidator::HIERARCHY_CYCLE,
			"cycle in hierarchy of entity 'B'"
		)
		model.assertError(
			EntitiesPackage::eINSTANCE.entity,
			EntitiesValidator::HIERARCHY_CYCLE,
			"cycle in hierarchy of entity 'C'"
		)
	}

	def void testDuplicateEntities() {
		val model = '''
entity MyEntity {}
entity MyEntity {}
'''.parse

		model.assertError(
			EntitiesPackage::eINSTANCE.entity,
			null,
			"Duplicate Entity 'MyEntity'"
		)
	}
}
