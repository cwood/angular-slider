(function() {
  var slider;

  slider = angular.module('ngSlider', ['ngTouch']);

  slider.directive('slider', function() {
    return {
      restrict: 'A',
      scope: true,
      controller: function($scope, $element, $window, $interval) {
        $scope.slides = [];
        $scope.leftPosition = $scope.currentIndex = $scope.totalWidth = 0;
        $scope.isLastSlide = false;
        $scope.isFirstSlide = true;
        $scope.$slider = $element;
        $scope.addSlide = function(slide, element) {
          slide.$element = element;
          $scope.slides.push(slide);
          if ($scope.defaultWidth === false) {
            return $scope.$watch(function() {
              return slide.$element.is(':visible');
            }, function() {
              return $scope.activeSlides = $scope.getActiveSlides();
            });
          } else {
            return $scope.activeSlides = $scope.getActiveSlides();
          }
        };
        $scope.getActiveSlides = function() {
          var activeSlides, slide, _i, _len, _ref;
          activeSlides = [];
          _ref = $scope.slides;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            slide = _ref[_i];
            if ($scope.defaultWidth && !$scope.$viewport.is(':visible')) {
              activeSlides.push(slide);
            } else if (slide.$element.is(':visible')) {
              activeSlides.push(slide);
            }
          }
          if (($scope._activeSlides != null) === activeSlides) {
            return activeSlides;
          } else {
            $scope._activeSlides = activeSlides;
            $scope.currentIndex = 0;
            $scope.leftPosition = 0;
            return activeSlides;
          }
        };
        $scope.$watch('totalWidth', function() {
          return $scope.totalWidth = Math.ceil($scope.totalWidth);
        });
        $scope.$watch('slides.length', function() {
          var slide, _i, _len, _ref, _results;
          $scope.activeSlides = $scope.getActiveSlides();
          _ref = $scope.activeSlides;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            slide = _ref[_i];
            _results.push($scope.totalWidth += slide.$element.outerWidth(true));
          }
          return _results;
        });
        angular.element($window).bind('orientationchange resize', function() {
          var currentSlide, slide, _i, _len, _ref;
          $scope.totalWidth = 0;
          $scope.activeSlides = $scope.getActiveSlides();
          _ref = $scope.activeSlides;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            slide = _ref[_i];
            $scope.totalWidth += slide.$element.outerWidth(true);
          }
          currentSlide = $scope.getCurrentSlide();
          $scope.goToSlide($scope.getCurrentSlide());
          return $scope.$digest();
        });
        $scope.getCurrentSlide = function() {
          return $scope.activeSlides[$scope.currentIndex];
        };
        $scope.goToSlide = function(manualSlide) {
          var index, leftPosition, slide, _i, _len, _ref;
          leftPosition = 0;
          index = 0;
          _ref = $scope.activeSlides;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            slide = _ref[_i];
            if (slide === manualSlide) {
              break;
            }
            index += 1;
            leftPosition += slide.$element.outerWidth(true);
          }
          $scope.leftPosition = -leftPosition;
          return $scope.currentIndex = index;
        };
        $scope.nextSlide = function() {
          var slide, totalInView, totalLeft;
          slide = $scope.activeSlides[$scope.currentIndex + 1];
          if ($scope.$viewport.slideMultiple) {
            totalInView = $scope.$viewport.width() / slide.$element.outerWidth(true);
            totalLeft = Math.round(totalInView) - totalInView;
            slide = $scope.activeSlides[$scope.currentIndex + Math.round(totalInView)];
            if (!slide && $scope.isLastSlide) {
              slide = $scope.activeSlides[$scope.activeSlides.length - 1];
              if ((totalLeft * 100) > 10) {
                $scope.offsetLeft = slide.$element.outerWidth(true) * totalLeft;
                $scope.leftPosition -= $scope.offsetLeft;
                $scope.isLastSlide = true;
              }
              slide = null;
            }
          }
          if (slide) {
            $scope.leftPosition -= slide.$element.outerWidth(true);
            return $scope.currentIndex += 1;
          }
        };
        $scope.$watch('currentIndex', function() {
          var currentSlide;
          currentSlide = $scope.getCurrentSlide();
          $scope.isLastSlide = (currentSlide === $scope.activeSlides[$scope.activeSlides.length - 1] ? true : false);
          return $scope.isFirstSlide = (currentSlide === $scope.activeSlides[0] ? true : false);
        });
        return $scope.prevSlide = function($event) {
          var slide;
          slide = $scope.activeSlides[$scope.currentIndex - 1];
          if ($scope.isLastSlide && !angular.isUndefined($scope.offsetLeft)) {
            $scope.leftPosition += $scope.offsetLeft;
            $scope.offsetLeft = null;
            $scope.isLastSlide = false;
          }
          if (slide) {
            $scope.leftPosition += slide.$element.outerWidth(true);
            return $scope.currentIndex -= 1;
          }
        };
      }
    };
  });

  slider.directive('sliderViewport', function() {
    return {
      restrict: 'E',
      require: '^slider',
      transclude: true,
      replace: true,
      template: "<div class='angular-slider-viewport'>\n  <ul data-ng-swipe-left='nextSlide($event);stopScroll=true'\n      data-ng-swipe-right='prevSlide($event);stopScroll=true'\n      data-ng-style='getViewportStyle()'\n      data-ng-transclude>\n  </ul>\n</div>",
      controller: function($scope, $element, $attrs, $interval) {
        var _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
        $scope.$viewport = $element;
        $scope.$viewport.slideMultiple = (_ref = $scope.$eval($attrs.slideMultiple)) != null ? _ref : false;
        $scope.autoScroll = (_ref1 = $scope.$eval($attrs.autoScroll)) != null ? _ref1 : false;
        $scope.defaultWidth = (_ref2 = $attrs.defaultWidth) != null ? _ref2 : false;
        $scope.widthOfWindow = (_ref3 = $attrs.widthOfWindow) != null ? _ref3 : false;
        $scope.autoScrollSpeed = (_ref4 = $attrs.autoScrollSpeed) != null ? _ref4 : 5000;
        if ($scope.autoScroll) {
          $scope.autoScrollSpeed = $attrs.autoScrollSpeed;
          $interval(function() {
            if (!$scope.stopScroll) {
              return $scope.nextSlide();
            }
          }, (_ref5 = $scope.autoScrollSpeed) != null ? _ref5 : 5000);
        }
        return $scope.getViewportStyle = function() {
          return {
            left: $scope.leftPostion + 'px',
            position: 'relative',
            width: $scope.totalWidth + 'px'
          };
        };
      }
    };
  });

  slider.directive('slide', function() {
    return {
      restrict: 'A',
      scope: true,
      controller: function($scope, $element, $attrs, $window, $document, $log) {
        $scope.isResponsive = false;
        $scope.responsiveWidth = {};
        $scope.addSlide($scope, $element);
        $scope.isActive = function() {
          return $element.is(':visbile');
        };
        $scope.getResponsiveWidth = function() {
          var hasDefault, responsiveWidth, _topWidth;
          _topWidth = 0;
          angular.forEach($scope.responsiveWidth, function(slideInPercent, width) {
            var intWidth;
            intWidth = parseInt(width);
            if (angular.element($window).width() <= intWidth) {
              return _topWidth = intWidth + 'px';
            }
          });
          if (_topWidth === 0) {
            hasDefault = $scope.responsiveWidth['default'];
            if (angular.isDefined(hasDefault)) {
              _topWidth = 'default';
            } else {
              angular.forEach($scope.responsiveWidth, function(slideInPercent, width) {
                var intWidth;
                intWidth = parseInt(width);
                if (intWidth >= parseInt(_topWidth)) {
                  return _topWidth = intWidth + 'px';
                }
              });
            }
          }
          responsiveWidth = parseInt($scope.responsiveWidth[_topWidth]);
          return Math.round(parseInt($scope.$slider.outerWidth(true)) * (responsiveWidth / 100));
        };
        $scope.getWidth = function() {
          var elementCssWidth;
          if ($scope.widthOfWindow) {
            return $($window).width();
          }
          if ($scope.defaultWidth) {
            return parseInt($scope.defaultWidth);
          }
          if ($scope.$viewport.slideMultiple && !$scope.isResponsive) {
            elementCssWidth = $element.outerWidth(true);
            return parseInt(elementCssWidth);
          }
          if ($scope.$viewport.slideMultiple && $scope.isResponsive) {
            return $scope.getResponsiveWidth();
          }
          return $scope.$viewport.outerWidth(true);
        };
        $element.width($scope.getWidth());
        $element.css({
          display: $element.css('display') !== 'none' ? 'inline-block' : 'none',
          float: 'left'
        });
        angular.element($window).bind('orientationchange resize', function() {
          if (!$scope.isResponsive) {
            return $element.width($scope.getWidth());
          } else {
            return $element.width($scope.getResponsiveWidth());
          }
        });
        return angular.forEach($attrs, function(value, key) {
          var slideInPercent, width;
          if (key.indexOf('maxWidth') === 0) {
            $scope.isResponsive = true;
            width = key.split('maxWidth')[1].toLowerCase();
            slideInPercent = value;
            return $scope.responsiveWidth[width] = value;
          }
        });
      }
    };
  });

}).call(this);

/*
//@ sourceMappingURL=angular-slider.js.map
*/