describe 'Alchemy integration', ->
  beforeEach ->
    #		setFixtures('<select id="myselect"></select>')
    #		jasmine.Ajax.useMock();
    #		request = FakeXMLHttpRequest()
    #		request.response(TestResponses.search.success)
    #		element = $('#myselect')
    #

  it 'should provide an Alchemy-Object', ->
    expect(Alchemy).toExist()

