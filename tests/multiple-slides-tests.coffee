describe "multiple slides off the viewport", ->

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
            <li slide style='width: 150px'>
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

  it "should toggle on slides multiple boolean", ->
    expect($scope.$viewport.slideMultiple).toBe true

  it "should have 5 active slides", ->
    expect($scope.activeSlides.length).toBe 5

  it "should have a total combined width", ->
    expect($scope.totalWidth).toBe(200*2 + 150*3)

  it "on next slide left should be -200px", ->
    $scope.nextSlide()
    expect($scope.leftPosition).toBe(-200)

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

  it "when on the last active slide last slide should be true", ->
    $scope.goToSlide($scope.activeSlides[$scope.activeSlides.length - 1])
    $scope.$apply()

    expect($scope.isLastSlide).toBe true
    expect($scope.isFirstSlide).toBe false
