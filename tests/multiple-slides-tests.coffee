describe "Multiple Slides Off The Viewport:", ->

  slider = $scope = null

  beforeEach module('ngSlider')

  beforeEach inject ($compile, $rootScope) ->
    $scope = $rootScope.$new()
    element = angular.element(
      """
        <div slider>
          <div data-ng-click='nextSlide()'>Next Slide</div>
          <slider-viewport slide-multiple='true' style='overflow: hidden; width: 600px; margin: 0;' >
            <li slide style='width: 150px'>
              <h1>Slide A</h1>
            </li>
            <li slide style='width: 150px'>
              <h1>Slide B</h1>
            </li>
            <li slide style='width: 150px'>
              <h1>Slide C</h1>
            </li>
            <li slide style='width: 150px'>
              <h1>Slide B</h1>
            </li>
            <li slide style='width: 150px'>
              <h1>Slide B</h1>
            </li>
          </slider-viewport>
          <div data-ng-click='prevSlide()'>Prev Slide</div>
        </div>
      """)

    slider = $compile(element)($scope)
    $('body').html(slider)
    slider.scope().$apply()
    $scope = slider.scope()

  it "should toggle on slides multiple boolean", ->
    expect($scope.slideMultiple).toBe true

  it "should have 5 active slides", ->
    expect($scope.activeSlides.length).toBe 5

  it "should have a total combined width", ->
    expect($scope.totalWidth).toBe(150*5)

  it "on next slide left should be -200px", ->
    $scope.nextSlide()
    expect($scope.leftPosition).toBe(-150)

  it "should be on the first slide and not the last slide", ->
    expect($scope.isFirstSlide).toBe true
    expect($scope.isLastSlide).toBe false


describe "multiple slides in the viewport", ->

  slider = $scope = null

  beforeEach module('ngSlider')

  beforeEach inject ($compile, $rootScope) ->
    $scope = $rootScope.$new()
    element = angular.element(
      """
        <div slider>
          <div data-ng-click='nextSlide()'>Next Slide</div>
          <slider-viewport slide-multiple='true' style='overflow: hidden; width: 600px; margin: 0;' >
            <li slide style='width: 150px'>
              <h1>Slide A</h1>
            </li>
            <li slide style='width: 200px'>
              <h1>Slide B</h1>
            </li>
            <li slide style='width: 150px'>
              <h1>Slide C</h1>
            </li>
          </slider-viewport>
          <div data-ng-click='prevSlide()'>Prev Slide</div>
        </div>
      """)

    slider = $compile(element)($scope)
    $('body').html(slider)
    slider.scope().$apply()
    $scope = slider.scope()

  it "should be multiple slides", ->
    expect($scope.slideMultiple).toBe true

  it "should be on both the first and last slide", ->
    expect($scope.isFirstSlide).toBe true
    expect($scope.isLastSlide).toBe true

describe "hidden slides", ->

  slider = $scope = null

  beforeEach module('ngSlider')

  beforeEach inject ($compile, $rootScope) ->
    $scope = $rootScope.$new()
    element = angular.element(
      """
        <div slider>
          <div data-ng-click='nextSlide()'>Next Slide</div>
          <slider-viewport slide-multiple='true' style='overflow: hidden; width: 600px; margin: 0;' >
            <li slide style='width: 150px'>
              <h1>Slide A</h1>
            </li>
            <li slide style='width: 200px'>
              <h1>Slide B</h1>
            </li>
            <li slide style='width: 150px'>
              <h1>Slide C</h1>
            </li>
            <li slide style='width: 200px'>
              <h1>Slide D</h1>
            </li>
            <li slide style='width: 150px; display: none;'>
              <h1>Slide E</h1>
            </li>
          </slider-viewport>
          <div data-ng-click='prevSlide()'>Prev Slide</div>
        </div>
      """)

    slider = $compile(element)($scope)
    $('body').html(slider)
    slider.scope().$apply()

    $scope = slider.scope()

  it "should have 4 active slides and one inactive", ->
    expect($scope.activeSlides.length).toBe 4

  it "the first slide should be active", ->
    expect($scope.isFirstSlide).toBe true

  it "when on the last active slide isLastSlide should be true and isFirstSlide should be true", ->
    $scope.goToSlide($scope.activeSlides[$scope.activeSlides.length - 1])
    $scope.$digest()
    expect($scope.isLastSlide).toBe true


describe "hidden slider at start with default slides", ->

  slider = $scope = null

  beforeEach module('ngSlider')

  beforeEach inject ($compile, $rootScope) ->
    $scope = $rootScope.$new()
    element = angular.element(
      """
        <div slider>
          <div data-ng-click='nextSlide()'>Next Slide</div>
          <slider-viewport slide-multiple='true' style='overflow: hidden; width: 600px; margin: 0; display: none;' default-width="150px" >
            <li slide>
              <h1>Slide A</h1>
            </li>
            <li slide>
              <h1>Slide B</h1>
            </li>
            <li slide>
              <h1>Slide C</h1>
            </li>
            <li slide>
              <h1>Slide D</h1>
            </li>
            <li slide>
              <h1>Slide E</h1>
            </li>
          </slider-viewport>
          <div data-ng-click='prevSlide()'>Prev Slide</div>
        </div>
      """)

    slider = $compile(element)($scope)
    $('body').html(slider)
    slider.scope().$apply()
    $scope = slider.scope()

  it "should still have 5 active slides even though slider is hidden", ->
    expect($scope.activeSlides.length).toBe 5

  it "should have a total width of 150 * 5 slides", ->
    expect($scope.totalWidth).toBe 150*5
