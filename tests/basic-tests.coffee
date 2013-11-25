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
    slider.scope().$apply()

  it 'should have 3 slides', ->
    expect(slider.scope().slides.length).toBe 3

  it 'should have 3 active slides', ->
    expect(slider.scope().activeSlides.length).toBe 3

  it 'should auto start scrolling as false', ->
    expect(slider.scope().autoScroll).toBe false

  it 'the viewport width to be 450px', ->
    expect(slider.scope().totalWidth).toBe 450
