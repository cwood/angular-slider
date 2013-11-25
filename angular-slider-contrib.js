(function() {
  var ngSliderContrib;

  ngSliderContrib = angular.module('ngSliderContrib', ['ngTouch', 'ngSlider']);

  ngSliderContrib.directive('sliderProgressBar', function() {
    return {
      restrict: 'E',
      require: '^slider',
      transclude: false,
      controller: function($scope, $element, $interval, $timeout) {
        var oldSlide, progressBar;
        progressBar = $element.find('.progress-bar').first();
        oldSlide = null;
        $scope.stopScroll = false;
        return $scope.$watch('currentIndex', function() {
          progressBar.removeClass('active');
          return $timeout(function() {
            if (!$scope.stopScroll) {
              return progressBar.addClass('active');
            }
          }, 100);
        });
      },
      template: "<div class='progress-bar-container' data-ng-class=\"{'stop-scrolling': stopScroll}\">\n  <div class='progress-bar'></div>\n</div>",
      replace: true
    };
  });

  ngSliderContrib.directive('setActiveSlide', function() {
    return {
      restrict: 'A',
      controller: function($scope, $element) {
        $scope.isActive = function(classSlug) {
          var currentSlide;
          currentSlide = $scope.getCurrentSlide();
          return currentSlide.$element.hasClass(classSlug);
        };
        return $scope.goToFirstInCategory = function(classSlug, $element) {
          var slide, slides;
          $scope.stopScroll = true;
          slides = (function() {
            var _i, _len, _ref, _results;
            _ref = $scope.slides;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              slide = _ref[_i];
              if (slide.$element.hasClass(classSlug)) {
                _results.push(slide);
              }
            }
            return _results;
          })();
          $scope.goToSlide(slides[0]);
          return $scope.$apply();
        };
      }
    };
  });

}).call(this);

/*
//@ sourceMappingURL=angular-slider-contrib.js.map
*/