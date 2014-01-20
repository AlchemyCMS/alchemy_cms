#= require jasmine-jquery

describe "Alchemy.Dialog", ->

  # beforeEach ->
  #   # first load the jasmine-jquery fixtures
  #   # loadFixtures('fixture.html')
  #   # then use ajax mocking
  #   jasmine.Ajax.useMock()

  afterEach ->
    @dialog.dialog.remove()
    if @dialog.overlay
      @dialog.overlay.remove()

  describe 'with default options', ->
    beforeEach ->
      @dialog = new Alchemy.Dialog('/events/new')

    it 'appends the dialog to the dom', ->
      expect($('.alchemy-dialog')).toHaveLength(1)

    it 'appends an overlay to the dom', ->
      expect($('.alchemy-dialog-overlay')).toHaveLength(1)

    it 'has a close button', ->
      expect($('.alchemy-dialog-close')).toHaveLength(1)

    it 'has a title bar', ->
      expect($('.alchemy-dialog-title')).toHaveLength(1)

    it 'has a body', ->
      expect($('.alchemy-dialog-body')).toHaveLength(1)

    it 'has width and height attributes', ->
      expect(@dialog.width).toEqual(400)
      expect(@dialog.height).toEqual(300)

    it 'has max-width and min-height styles', ->
      expect(@dialog.dialog).toHaveCss({'max-width': '400px', 'min-height': '300px'})

    describe '#open', ->
      beforeEach ->
        @dialog.open()

      it 'adds "open" class to the dialog', ->
        expect(@dialog.dialog).toHaveClass('open')

      it 'adds "open" class to the overlay', ->
        expect(@dialog.overlay).toHaveClass('open')

      it 'attaches "#close" click event to close button', ->
        expect(@dialog.close_button).toHandleWith('click', @dialog.close)

      it 'attaches "#close" click event to overlay', ->
        expect(@dialog.overlay).toHandleWith('click', @dialog.close)

      it 'attaches "#close" key event to esc key', ->
        expect(@dialog.$document).toHandle('keydown')

    describe '#load', ->
      beforeEach ->
        @dialog.load()

      it 'shows a spinner', ->
        expect(@dialog.dialog_body.find('.spinner')).toHaveLength(1)

      xit 'loads content via ajax'

  describe 'with modal set to false', ->
    beforeEach ->
      @dialog = new Alchemy.Dialog('/events/new', {modal: false})

    it 'does not append the overlay to the dom', ->
      expect($('.alchemy-dialog-overlay').length).toEqual(0)

  describe 'with title given', ->
    beforeEach ->
      @dialog = new Alchemy.Dialog('/events/new', {title: 'My Title'})

    it 'has a title', ->
      expect($('.alchemy-dialog-title')).toContainText('My Title')
