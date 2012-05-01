/*
Copyright (c) 2012 Josh Tynjala

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
package org.josht.starling.foxhole.controls
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import org.josht.starling.foxhole.core.FoxholeControl;
	import org.josht.utils.math.clamp;
	import org.josht.utils.math.roundToNearest;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	/**
	 * Select a value between a minimum and a maximum by dragging a thumb over
	 * the bounds of a track.
	 */
	public class Slider extends FoxholeControl
	{
		/**
		 * The slider's thumb may be dragged horizontally (on the x-axis).
		 */
		public static const DIRECTION_HORIZONTAL:String = "horizontal";
		
		/**
		 * The slider's thumb may be dragged vertically (on the y-axis).
		 */
		public static const DIRECTION_VERTICAL:String = "vertical";

		/**
		 * The slider's minimum and maximum track will by resized by changing
		 * their width and height values. Consider using a special display
		 * object such as a Scale9Image, Scale3Image or a TiledImage if the
		 * skins should be resizable.
		 */
		public static const TRACK_LAYOUT_MODE_STRETCH:String = "stretch";

		/**
		 * The slider's minimum and maximum tracks will be resized and cropped
		 * using a scrollRect to ensure that the skins maintain a static
		 * appearance without any stretching.
		 */
		public static const TRACK_LAYOUT_MODE_SCROLL:String = "scroll";
		
		/**
		 * Constructor.
		 */
		public function Slider()
		{
			super();
		}
		
		/**
		 * @private
		 */
		protected var minimumTrack:Button;

		/**
		 * @private
		 */
		protected var maximumTrack:Button;

		/**
		 * @private
		 */
		protected var minimumTrackOriginalWidth:Number = NaN;

		/**
		 * @private
		 */
		protected var minimumTrackOriginalHeight:Number = NaN;

		/**
		 * @private
		 */
		protected var maximumTrackOriginalWidth:Number = NaN;

		/**
		 * @private
		 */
		protected var maximumTrackOriginalHeight:Number = NaN;
		
		/**
		 * @private
		 */
		protected var thumb:Button;
		
		/**
		 * @private
		 */
		protected var _onChange:Signal = new Signal(Slider);
		
		/**
		 * Dispatched when the <code>value</code> property changes.
		 */
		public function get onChange():ISignal
		{
			return this._onChange;
		}
		
		/**
		 * @private
		 */
		private var _direction:String = DIRECTION_HORIZONTAL;
		
		/**
		 * Determines if the slider's thumb can be dragged horizontally or
		 * vertically. When this value changes, the slider's width and height
		 * values do not change automatically.
		 */
		public function get direction():String
		{
			return this._direction;
		}
		
		/**
		 * @private
		 */
		public function set direction(value:String):void
		{
			if(this._direction == value)
			{
				return;
			}
			this._direction = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		/**
		 * @private
		 */
		private var _value:Number = 0;
		
		/**
		 * The value of the slider, between the minimum and maximum.
		 */
		public function get value():Number
		{
			return this._value;
		}
		
		/**
		 * @private
		 */
		public function set value(newValue:Number):void
		{
			if(this._step != 0)
			{
				newValue = roundToNearest(newValue, this._step);
			}
			newValue = clamp(newValue, this._minimum, this._maximum);
			if(this._value == newValue)
			{
				return;
			}
			this._value = newValue;
			this.invalidate(INVALIDATION_FLAG_DATA);
			if(this.liveDragging || !this.isDragging)
			{
				this._onChange.dispatch(this);
			}
		}
		
		/**
		 * @private
		 */
		private var _minimum:Number = 0;
		
		/**
		 * The slider's value will not go lower than the minimum.
		 */
		public function get minimum():Number
		{
			return this._minimum;
		}
		
		/**
		 * @private
		 */
		public function set minimum(value:Number):void
		{
			if(this._minimum == value)
			{
				return;
			}
			this._minimum = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		/**
		 * @private
		 */
		private var _maximum:Number = 0;
		
		/**
		 * The slider's value will not go higher than the maximum.
		 */
		public function get maximum():Number
		{
			return this._maximum;
		}
		
		/**
		 * @private
		 */
		public function set maximum(value:Number):void
		{
			if(this._maximum == value)
			{
				return;
			}
			this._maximum = value;
			this.invalidate(INVALIDATION_FLAG_DATA);
		}
		
		/**
		 * @private
		 */
		private var _step:Number = 0;
		
		/**
		 * As the slider's thumb is dragged, the value is snapped to a multiple
		 * of the step.
		 */
		public function get step():Number
		{
			return this._step;
		}
		
		/**
		 * @private
		 */
		public function set step(value:Number):void
		{
			if(this._step == value)
			{
				return;
			}
			this._step = value;
		}
		
		/**
		 * @private
		 */
		protected var isDragging:Boolean = false;
		
		/**
		 * Determines if the slider dispatches the onChange signal every time
		 * the thumb moves, or only once it stops moving.
		 */
		public var liveDragging:Boolean = true;
		
		/**
		 * @private
		 */
		private var _showThumb:Boolean = true;
		
		/**
		 * Determines if the thumb should be displayed. This stops interaction
		 * while still displaying the track.
		 */
		public function get showThumb():Boolean
		{
			return this._showThumb;
		}
		
		/**
		 * @private
		 */
		public function set showThumb(value:Boolean):void
		{
			if(this._showThumb == value)
			{
				return;
			}
			this._showThumb = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}

		/**
		 * @private
		 */
		private var _trackLayoutMode:String = TRACK_LAYOUT_MODE_STRETCH;

		/**
		 * Determines how the minimum and maximum track skins are positioned and
		 * sized.
		 */
		public function get trackLayoutMode():String
		{
			return this._trackLayoutMode;
		}

		/**
		 * @private
		 */
		public function set trackLayoutMode(value:String):void
		{
			if(this._trackLayoutMode == value)
			{
				return;
			}
			this._trackLayoutMode = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}

		/**
		 * @private
		 */
		private var _minimumTrackProperties:Object = {};

		/**
		 * A set of key/value pairs to be passed down to the slider's minimum
		 * track instance. The minimum track is a Foxhole Button control.
		 */
		public function get minimumTrackProperties():Object
		{
			return this._minimumTrackProperties;
		}

		/**
		 * @private
		 */
		public function set minimumTrackProperties(value:Object):void
		{
			if(this._minimumTrackProperties == value)
			{
				return;
			}
			if(!value)
			{
				value = {};
			}
			this._minimumTrackProperties = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		/**
		 * @private
		 */
		private var _maximumTrackProperties:Object = {};
		
		/**
		 * A set of key/value pairs to be passed down to the slider's maximum
		 * track instance. The maximum track is a Foxhole Button control.
		 */
		public function get maximumTrackProperties():Object
		{
			return this._maximumTrackProperties;
		}
		
		/**
		 * @private
		 */
		public function set maximumTrackProperties(value:Object):void
		{
			if(this._maximumTrackProperties == value)
			{
				return;
			}
			if(!value)
			{
				value = {};
			}
			this._maximumTrackProperties = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		/**
		 * @private
		 */
		private var _thumbProperties:Object = {};
		
		/**
		 * A set of key/value pairs to be passed down to the slider's thumb
		 * instance. The thumb is a Foxhole Button control.
		 */
		public function get thumbProperties():Object
		{
			return this._thumbProperties;
		}
		
		/**
		 * @private
		 */
		public function set thumbProperties(value:Object):void
		{
			if(this._thumbProperties == value)
			{
				return;
			}
			if(!value)
			{
				value = {};
			}
			this._thumbProperties = value;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		private var _touchPointID:int = -1;
		private var _touchStartX:Number = NaN;
		private var _touchStartY:Number = NaN;
		private var _thumbStartX:Number = NaN;
		private var _thumbStartY:Number = NaN;
		
		/**
		 * Sets a single property on the slider's thumb instance. The thumb is
		 * a Foxhole Button control.
		 */
		public function setThumbProperty(propertyName:String, propertyValue:Object):void
		{
			this._thumbProperties[propertyName] = propertyValue;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		/**
		 * Sets a single property on the slider's minimum track instance. The
		 * minimum track is a Foxhole Button control.
		 */
		public function setMinimumTrackProperty(propertyName:String, propertyValue:Object):void
		{
			this._minimumTrackProperties[propertyName] = propertyValue;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}

		/**
		 * Sets a single property on the slider's maximum track instance. The
		 * maximum track is a Foxhole Button control.
		 */
		public function setMaximumTrackProperty(propertyName:String, propertyValue:Object):void
		{
			this._maximumTrackProperties[propertyName] = propertyValue;
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			this._onChange.removeAll();
			super.dispose();
		}
		
		/**
		 * @private
		 */
		override protected function initialize():void
		{
			if(!this.minimumTrack)
			{
				this.minimumTrack = new Button();
				this.minimumTrack.nameList.add("foxhole-slider-minimum-track");
				this.minimumTrack.label = "";
				this.minimumTrack.addEventListener(TouchEvent.TOUCH, track_touchHandler);
				this.addChild(this.minimumTrack);
			}

			if(!this.maximumTrack)
			{
				this.maximumTrack = new Button();
				this.maximumTrack.nameList.add("foxhole-slider-maximum-track");
				this.maximumTrack.label = "";
				this.maximumTrack.addEventListener(TouchEvent.TOUCH, track_touchHandler);
				this.addChild(this.maximumTrack);
			}
			
			if(!this.thumb)
			{
				this.thumb = new Button();
				this.thumb.nameList.add("foxhole-slider-thumb");
				this.thumb.label = "";
				this.thumb.keepDownStateOnRollOut = true;
				this.thumb.addEventListener(TouchEvent.TOUCH, thumb_touchHandler);
				this.addChild(this.thumb);
			}
		}
		
		/**
		 * @private
		 */
		override protected function draw():void
		{
			const dataInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_DATA);
			const stylesInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_STYLES);
			var sizeInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_SIZE);
			const stateInvalid:Boolean = this.isInvalid(INVALIDATION_FLAG_STATE);
			
			if(stylesInvalid)
			{
				this.refreshThumbStyles();
				this.refreshTrackStyles();
			}
			
			if(stateInvalid)
			{
				this.thumb.isEnabled = this.minimumTrack.isEnabled =
					this.maximumTrack.isEnabled = this._isEnabled;
			}

			sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;

			if(dataInvalid || stylesInvalid || sizeInvalid)
			{
				this.layout();
			}
		}

		/**
		 * @private
		 */
		protected function autoSizeIfNeeded():Boolean
		{
			if(isNaN(this.minimumTrackOriginalWidth) || isNaN(this.minimumTrackOriginalHeight))
			{
				this.minimumTrack.validate();
				this.minimumTrackOriginalWidth = this.minimumTrack.width;
				this.minimumTrackOriginalHeight = this.minimumTrack.height;
			}
			if(isNaN(this.maximumTrackOriginalWidth) || isNaN(this.maximumTrackOriginalHeight))
			{
				this.maximumTrack.validate();
				this.maximumTrackOriginalWidth = this.maximumTrack.width;
				this.maximumTrackOriginalHeight = this.maximumTrack.height;
			}

			const needsWidth:Boolean = isNaN(this.explicitWidth);
			const needsHeight:Boolean = isNaN(this.explicitHeight);
			if(!needsWidth && !needsHeight)
			{
				return false;
			}
			this.thumb.validate();
			var newWidth:Number = this.explicitWidth;
			var newHeight:Number = this.explicitHeight;
			if(needsWidth)
			{
				if(this._direction == DIRECTION_VERTICAL)
				{
					newWidth = Math.max(this.minimumTrackOriginalWidth, this.maximumTrackOriginalWidth);
				}
				else //horizontal
				{
					newWidth = Math.min(this.minimumTrackOriginalWidth, this.maximumTrackOriginalWidth) + this.thumb.width / 2;
				}
			}
			if(needsHeight)
			{
				if(this._direction == DIRECTION_VERTICAL)
				{
					newHeight = Math.min(this.minimumTrackOriginalHeight, this.maximumTrackOriginalHeight) + this.thumb.height / 2;
				}
				else //horizontal
				{
					newHeight = Math.max(this.minimumTrackOriginalHeight, this.maximumTrackOriginalHeight);
				}
			}
			this.setSizeInternal(newWidth, newHeight, false);
			return true;
		}
		
		/**
		 * @private
		 */
		protected function refreshThumbStyles():void
		{
			for(var propertyName:String in this._thumbProperties)
			{
				if(this.thumb.hasOwnProperty(propertyName))
				{
					var propertyValue:Object = this._thumbProperties[propertyName];
					this.thumb[propertyName] = propertyValue;
				}
			}
			this.thumb.visible = this._showThumb;
		}
		
		/**
		 * @private
		 */
		protected function refreshTrackStyles():void
		{
			for(var propertyName:String in this._minimumTrackProperties)
			{
				if(this.minimumTrack.hasOwnProperty(propertyName))
				{
					var propertyValue:Object = this._minimumTrackProperties[propertyName];
					this.minimumTrack[propertyName] = propertyValue;
				}
			}
			for(propertyName in this._maximumTrackProperties)
			{
				if(this.maximumTrack.hasOwnProperty(propertyName))
				{
					propertyValue = this._maximumTrackProperties[propertyName];
					this.maximumTrack[propertyName] = propertyValue;
				}
			}
		}

		/**
		 * @private
		 */
		protected function layout():void
		{
			//this will auto-size the thumb, if needed
			this.thumb.validate();

			if(this._direction == DIRECTION_VERTICAL)
			{
				const trackScrollableHeight:Number = this.actualHeight - this.thumb.height;
				this.thumb.x = (this.actualWidth - this.thumb.width) / 2;
				this.thumb.y = (trackScrollableHeight * (this._value - this._minimum) / (this._maximum - this._minimum));
			}
			else
			{
				const trackScrollableWidth:Number = this.actualWidth - this.thumb.width;
				this.thumb.x = (trackScrollableWidth * (this._value - this._minimum) / (this._maximum - this._minimum));
				this.thumb.y = (this.actualHeight - this.thumb.height) / 2;
			}

			if(this._trackLayoutMode == TRACK_LAYOUT_MODE_SCROLL)
			{
				this.layoutTrackWithScrollRect();
			}
			else //stretch
			{
				this.layoutTrackWithStretch();
			}
		}

		/**
		 * @private
		 */
		protected function layoutTrackWithScrollRect():void
		{
			if(this._direction == DIRECTION_VERTICAL)
			{
				//we want to scale the skins to match the height of the slider,
				//but we also want to keep the original aspect ratio.
				const minimumTrackScaledHeight:Number = this.minimumTrackOriginalHeight * this.actualWidth / this.minimumTrackOriginalWidth;
				const maximumTrackScaledHeight:Number = this.maximumTrackOriginalHeight * this.actualWidth / this.maximumTrackOriginalWidth;
				this.minimumTrack.width = this.actualWidth;
				this.minimumTrack.height = minimumTrackScaledHeight;
				this.maximumTrack.width = this.actualWidth;
				this.maximumTrack.height = maximumTrackScaledHeight;

				var middleOfThumb:Number = this.thumb.y + this.thumb.height / 2;
				var currentScrollRect:Rectangle = this.minimumTrack.scrollRect;
				if(!currentScrollRect)
				{
					currentScrollRect = new Rectangle();
				}
				currentScrollRect.width = this.actualWidth;
				currentScrollRect.height = Math.min(minimumTrackScaledHeight, middleOfThumb);
				this.minimumTrack.scrollRect = currentScrollRect;

				this.maximumTrack.x = 0;
				this.maximumTrack.y = Math.max(this.actualHeight - maximumTrackScaledHeight, middleOfThumb);
				currentScrollRect = this.maximumTrack.scrollRect;
				if(!currentScrollRect)
				{
					currentScrollRect = new Rectangle();
				}
				currentScrollRect.width = this.actualWidth;
				currentScrollRect.height = Math.min(maximumTrackScaledHeight, this.actualHeight - middleOfThumb);
				currentScrollRect.x = 0;
				currentScrollRect.y = Math.max(0, maximumTrackScaledHeight - currentScrollRect.height);
				this.maximumTrack.scrollRect = currentScrollRect;
			}
			else //horizontal
			{
				//we want to scale the skins to match the height of the slider,
				//but we also want to keep the original aspect ratio.
				const minimumTrackScaledWidth:Number = this.minimumTrackOriginalWidth * this.actualHeight / this.minimumTrackOriginalHeight;
				const maximumTrackScaledWidth:Number = this.maximumTrackOriginalWidth * this.actualHeight / this.maximumTrackOriginalHeight;
				this.minimumTrack.width = minimumTrackScaledWidth;
				this.minimumTrack.height = this.actualHeight;
				this.maximumTrack.width = maximumTrackScaledWidth;
				this.maximumTrack.height = this.actualHeight;

				middleOfThumb = this.thumb.x + this.thumb.width / 2;
				currentScrollRect = this.minimumTrack.scrollRect;
				if(!currentScrollRect)
				{
					currentScrollRect = new Rectangle();
				}
				currentScrollRect.width = Math.min(minimumTrackScaledWidth, middleOfThumb);
				currentScrollRect.height = this.actualHeight;
				this.minimumTrack.scrollRect = currentScrollRect;

				this.maximumTrack.x = Math.max(this.actualWidth - maximumTrackScaledWidth, middleOfThumb);
				this.maximumTrack.y = 0;
				currentScrollRect = this.maximumTrack.scrollRect;
				if(!currentScrollRect)
				{
					currentScrollRect = new Rectangle();
				}
				currentScrollRect.width = Math.min(maximumTrackScaledWidth, this.actualWidth - middleOfThumb);
				currentScrollRect.height = this.actualHeight;
				currentScrollRect.x = Math.max(0, maximumTrackScaledWidth - currentScrollRect.width);
				currentScrollRect.y = 0;
				this.maximumTrack.scrollRect = currentScrollRect;
			}
		}

		/**
		 * @private
		 */
		protected function layoutTrackWithStretch():void
		{
			if(this.minimumTrack.scrollRect)
			{
				this.minimumTrack.scrollRect = null;
			}
			if(this.maximumTrack.scrollRect)
			{
				this.maximumTrack.scrollRect = null;
			}

			if(this._direction == DIRECTION_VERTICAL)
			{
				this.minimumTrack.width = this.actualWidth;
				this.minimumTrack.height = this.thumb.y + this.thumb.height / 2;
				this.maximumTrack.x = 0;
				this.maximumTrack.y = this.minimumTrack.height;
				this.maximumTrack.width = this.actualWidth;
				this.maximumTrack.height = this.actualHeight - this.maximumTrack.y;
			}
			else //horizontal
			{
				this.minimumTrack.width = this.thumb.x + this.thumb.width / 2;
				this.minimumTrack.height = this.actualHeight;
				this.maximumTrack.x = this.minimumTrack.width;
				this.maximumTrack.y = 0;
				this.maximumTrack.width = this.actualWidth - this.maximumTrack.x;
				this.maximumTrack.height = this.actualHeight;
			}
		}
		
		/**
		 * @private
		 */
		private function track_touchHandler(event:TouchEvent):void
		{
			if(!this._isEnabled)
			{
				return;
			}
			const touch:Touch = event.getTouch(DisplayObject(event.currentTarget));
			if(!touch || touch.phase != TouchPhase.ENDED || this._touchPointID >= 0)
			{
				return;
			}
			var location:Point = touch.getLocation(this);
			var percentage:Number;
			if(this._direction == DIRECTION_HORIZONTAL)
			{
				percentage = location.x / this.actualWidth;
			}
			else //vertical
			{
				percentage = location.y / this.actualHeight;
			}
			
			this.value = this._minimum + percentage * (this._maximum - this._minimum);
		}
		
		/**
		 * @private
		 */
		private function thumb_touchHandler(event:TouchEvent):void
		{
			if(!this._isEnabled)
			{
				return;
			}
			const touch:Touch = event.getTouch(this.thumb);
			if(!touch || (this._touchPointID >= 0 && this._touchPointID != touch.id))
			{
				return;
			}
			var location:Point = touch.getLocation(this);
			if(touch.phase == TouchPhase.BEGAN)
			{
				this._touchPointID = touch.id;
				this._thumbStartX = this.thumb.x;
				this._thumbStartY = this.thumb.y;
				this._touchStartX = location.x;
				this._touchStartY = location.y;
				this.isDragging = true;
			}
			else if(touch.phase == TouchPhase.MOVED)
			{
				var percentage:Number;
				if(this._direction == DIRECTION_HORIZONTAL)
				{
					const trackScrollableWidth:Number = this.actualWidth - this.thumb.width;
					const xOffset:Number = location.x - this._touchStartX;
					const xPosition:Number = Math.min(Math.max(0, this._thumbStartX + xOffset), trackScrollableWidth);
					percentage = xPosition / trackScrollableWidth;
				}
				else //vertical
				{
					const trackScrollableHeight:Number = this.actualHeight - this.thumb.height;
					const yOffset:Number = location.y - this._touchStartY;
					const yPosition:Number = Math.min(Math.max(0, this._thumbStartY + yOffset), trackScrollableHeight);
					percentage = yPosition / trackScrollableHeight;
				}
				
				this.value = this._minimum + percentage * (this._maximum - this._minimum);
			}
			else if(touch.phase == TouchPhase.ENDED)
			{
				this._touchPointID = -1;
				this.isDragging = false;
				if(!this.liveDragging)
				{
					this._onChange.dispatch(this);
				}
			}
		}
	}
}