describe "cache", ->

	beforeEach ->
		setFixtures('<div id="myelement"></div>')

	it "", ->
		expect(element.data("namedcache")).toEqual {}

	it "should throw an error", ->
		expect(->
			 
		).toThrow
			name: "Error"
			message: "..."

	describe "should not interfere with another instance", ->
		beforeEach ->

		it "should a", ->
			expect().toEqual 'value1'
		it "should not b", ->
			expect().toEqual null

	describe "method", ->
		it "should ....", ->

