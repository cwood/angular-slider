describe "the core slider ", ->

  slider = $scope = null

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

    $scope = slider.scope()

  it 'should have 3 slides', ->
    expect($scope.slides.length).toBe 3

  it 'should have 3 active slides', ->
    expect($scope.activeSlides.length).toBe 3

  it 'should auto start scrolling as false', ->
    expect($scope.autoScroll).toBe false

  it 'the viewport width to be 450px', ->
    expect($scope.totalWidth).toBe 450

  it 'should allow us to go to a specific slide', ->
    secondSlide = $scope.activeSlides[1]
    $scope.goToSlide(secondSlide)
    currentSlide = $scope.getCurrentSlide()
    expect(currentSlide).toBe(secondSlide)

  it 'should allow us to move to the next slide', ->
    $scope.nextSlide()
    activeSlide = $scope.getCurrentSlide()
    expect(activeSlide).toBe($scope.activeSlides[1])

  it 'should allow us to move to the prev slide', ->
    $scope.nextSlide()
    activeSlide = $scope.getCurrentSlide()

    expect(activeSlide).toBe($scope.activeSlides[1])
    expect($scope.leftPosition).toBe -150

    $scope.prevSlide()
    activeSlide = $scope.getCurrentSlide()

    expect(activeSlide).toBe($scope.activeSlides[0])
    expect($scope.leftPosition).toBe 0

  it 'shouldn\'t allow us to move past the last slide', ->
    $scope.goToSlide($scope.activeSlides[$scope.activeSlides.length - 1])
    $scope.nextSlide()

    expect($scope.currentIndex).toBe 2

    # should remain on 2 regardless since this is the last slide
    $scope.nextSlide()
    expect($scope.currentIndex).toBe 2

  it 'shoudn\'t allow us to move past the first slide', ->

    $scope.prevSlide()
    expect($scope.currentIndex).toBe 0

    # if user runs this function twice
    $scope.prevSlide()
    expect($scope.currentIndex).toBe 0

  it 'should set first slide to true when on the first slide', ->
    expect($scope.isFirstSlide).toBe true

    $scope.nextSlide()
    $scope.$apply() # since we are running this through karma

    expect($scope.isFirstSlide).toBe false

  it 'should set last slide to true when on the last slide', ->
    expect($scope.isLastSlide).toBe false

    $scope.goToSlide($scope.activeSlides[$scope.activeSlides.length - 1])
    $scope.$apply() # since we are running this through karma

    expect($scope.isLastSlide).toBe true
