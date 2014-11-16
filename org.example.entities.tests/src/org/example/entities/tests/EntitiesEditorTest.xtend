package org.example.entities.tests

import org.eclipse.core.resources.IResource
import org.eclipse.emf.ecore.EValidator
import org.eclipse.xtext.junit4.ui.AbstractEditorTest
import org.eclipse.xtext.ui.XtextProjectHelper
import org.example.entities.entities.EntitiesFactory
import org.example.entities.entities.Model
import org.junit.Before
import org.junit.Test

import static extension org.eclipse.xtext.junit4.ui.util.IResourcesSetupUtil.*
import static extension org.eclipse.xtext.junit4.ui.util.JavaProjectSetupUtil.*

class EntitiesEditorTest extends AbstractEditorTest {
	val TEST_PROJECT = "mytestproject"

	@Before
	override void setUp() {
		super.setUp
		createJavaProjectWithXtextNature
	}

	def void createJavaProjectWithXtextNature() {
		createJavaProject(TEST_PROJECT) => [
			getProject().addNature(XtextProjectHelper::NATURE_ID)
			addSourceFolder("entities-gen")
		]
	}

	def void checkEntityProgram(String contents, int expectedErrors) {
		val file = createFile(TEST_PROJECT + "/src/test.entities", contents)
		waitForAutoBuild();
		assertEquals(expectedErrors, file.findMarkers(EValidator::MARKER, true, IResource::DEPTH_INFINITE).size);
	}

	override protected getEditorId() {
		"org.example.entities.Entities"
	}

	def createTestFile(String contents) {
		createFile(TEST_PROJECT + "/src/test.entities", contents)
	}

	@Test
	def void testEntitiesEditor() {
		createTestFile("entity E {}").openEditor
	}

	@Test
	def void testEntitiesEditorContentsAsModel() {
		"E".assertEquals(
			createTestFile("entity E {}").openEditor.document.readOnly [
				// 'it' is an XtextResource
				contents.get(0) as Model
			].entities.get(0).name
		)
	}

	@Test
	def void testChangeContents() {
		val editor = createTestFile("entity E {}").openEditor
		editor.document.modify [
			val model = (contents.get(0) as Model)
			val currentEntity = model.entities.get(0)
			model.entities += EntitiesFactory::eINSTANCE.createEntity => [
				name = "Added"
				superType = currentEntity
			]
		]
		'''
entity E {}

entity Added extends E {
}'''.toString.assertEquals(editor.document.get)
	}

	@Test
	def void testEntitiesEditorContents() {
		"entity E {}".assertEquals(createTestFile("entity E {}").openEditor.document.get)
	}
	
	
}
