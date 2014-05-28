describe "core slider", ->

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
    $('body').html(slider)
    slider.scope().$apply()

    $scope = slider.scope()

  it 'should have 3 slides', ->
    expect($scope.slides.length).toBe 3

  it 'should have 3 active slides', ->
    expect($scope.activeSlides.length).toBe 3

  it 'should keep active slides even on the next slide', ->
    $scope.nextSlide().then ->
      expect($scope.currentIndex).toBe 1
      expect($scope.leftPosition).toBe -150

  it 'should auto start scrolling as false', ->
    expect($scope.autoScroll).toBe false

  it 'the viewport width to be 450px', ->
    expect($scope.totalWidth).toBe 450

  it 'should allow us to go to a specific slide', ->
    secondSlide = $scope.activeSlides[1]
    $scope.goToSlide(secondSlide).then ->
      currentSlide = $scope.getCurrentSlide()
      expect(currentSlide).toBe(secondSlide)

  it 'next slide should return a promise', ->
    promise = $scope.nextSlide()
    expect(promise.then).toBeDefined()

  it 'should allow us to move to the next slide', ->
    promise = $scope.nextSlide()
    promise.then ->
      activeSlide = $scope.getCurrentSlide()
      expect(activeSlide).toBe($scope.activeSlides[1])

      expect($scope.leftPosition).toBe -150

  it 'should allow us to move to the prev slide', ->
    promise = $scope.nextSlide()
    promise.then ->
      activeSlide = $scope.getCurrentSlide()

      expect(activeSlide).toBe($scope.activeSlides[1])
      expect($scope.leftPosition).toBe -150

    $scope.prevSlide().then ->
      activeSlide = $scope.getCurrentSlide()

      expect(activeSlide).toBe($scope.activeSlides[0])
      expect($scope.leftPosition).toBe 0

  it 'shouldn\'t allow us to move past the last slide', ->
    $scope.goToSlide($scope.activeSlides[$scope.activeSlides.length - 1]).then ->
      promise = $scope.nextSlide()

      promise.then ->
        expect($scope.currentIndex).toBe 2

      # should remain on 2 regardless since this is the last slide
      anotherPromise = $scope.nextSlide()
      anotherPromise.then ->
        expect($scope.currentIndex).toBe 2

  it 'shoudn\'t allow us to move past the first slide', ->

    $scope.prevSlide().then ->
      expect($scope.currentIndex).toBe 0

    # if user runs this function twice
    $scope.prevSlide().then ->
      expect($scope.currentIndex).toBe 0

  it 'should set first slide to true when on the first slide', ->
    expect($scope.isFirstSlide).toBe true

    promise = $scope.nextSlide()
    promise.then ->
      expect($scope.isFirstSlide).toBe false

  it 'should set last slide to true when on the last slide', ->
    expect($scope.isLastSlide).toBe false

    $scope.goToSlide($scope.activeSlides[$scope.activeSlides.length - 1]).then ->
      expect($scope.isLastSlide).toBe true

  it "should still have 3 active slides when viewport is hidden", ->
    $scope.$viewport.hide()
    expect($scope.activeSlides.length).toBe 3

  it "it should still have a total widh of 450px when the viewport is hidden", ->
    $scope.$viewport.hide()
    expect($scope.totalWidth).toBe 450
