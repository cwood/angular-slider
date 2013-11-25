describe "the core slider test", ->

  slider = null

  beforeEach module('ngSlider')

  beforeEach inject ($compile, $rootScope) ->
    $scope = $rootScope.$new()
    element = angular.element(
      """
        <div slider>
          <div data-ng-click='nextSlide()'>Next Slide</div>
          <slider-viewport default-width="150px">
            <li slide>
              <h1>Slide A</h1>
            </li>
            <li slide>
              <h1>Slide B</h1>
            </li>
            <li slide>
              <h1>Slide C</h1>
            </li>
          </slider-viewport>
          <div data-ng-click='prevSlide()'>Prev Slide</div>
        </div>
      """)

    slider = $compile(element)($scope)
    $(slider).appendTo('body')
    slider.scope().$apply()

  it 'should have 3 slides', ->
    expect(slider.scope().slides.length).toBe 3

  it 'should have 3 active slides', ->
    expect(slider.scope().activeSlides.length).toBe 3

  it 'should auto start scrolling as false', ->
    expect(slider.scope().autoScroll).toBe false

  it 'the viewport width to be 450px', ->
    expect(slider.scope().totalWidth).toBe 450

  it 'should allow us to go to a specific slide', ->
    secondSlide = slider.scope().activeSlides[1]
    slider.scope().goToSlide(secondSlide)
    currentSlide = slider.scope().getCurrentSlide()
    expect(currentSlide).toBe(secondSlide)

  it 'should allow us to move to the next slide', ->
    slider.scope().nextSlide()
    activeSlide = slider.scope().getCurrentSlide()
    expect(activeSlide).toBe(slider.scope().activeSlides[1])

  it 'should allow us to move to the prev slide', ->
    slider.scope().nextSlide()
    activeSlide = slider.scope().getCurrentSlide()

    expect(activeSlide).toBe(slider.scope().activeSlides[1])
    expect(slider.scope().leftPosition).toBe -150

    slider.scope().prevSlide()
    activeSlide = slider.scope().getCurrentSlide()

    expect(activeSlide).toBe(slider.scope().activeSlides[0])
    expect(slider.scope().leftPosition).toBe 0

  it 'shouldn\'t allow us to move past the last slide', ->
    slider.scope().goToSlide(slider.scope().activeSlides[slider.scope().activeSlides.length - 1])
    slider.scope().nextSlide()

    expect(slider.scope().currentIndex).toBe 2

    # should remain on 2 regardless since this is the last slide
    slider.scope().nextSlide()
    expect(slider.scope().currentIndex).toBe 2

  it 'shoudn\'t allow us to move past the first slide', ->

    slider.scope().prevSlide()
    expect(slider.scope().currentIndex).toBe 0

    # if user runs this function twice
    slider.scope().prevSlide()
    expect(slider.scope().currentIndex).toBe 0

  it 'should set first slide to true when on the first slide', ->
    expect(slider.scope().isFirstSlide).toBe true

    slider.scope().nextSlide()
    slider.scope().$apply() # since we are running this through karma

    expect(slider.scope().isFirstSlide).toBe false

  it 'should set last slide to true when on the last slide', ->
    expect(slider.scope().isLastSlide).toBe false

    slider.scope().goToSlide(slider.scope().activeSlides[slider.scope().activeSlides.length - 1])
    slider.scope().$apply() # since we are running this through karma

    expect(slider.scope().isLastSlide).toBe true
