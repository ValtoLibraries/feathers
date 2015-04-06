/*
Feathers
Copyright 2012-2015 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.media
{
	/**
	 * Event <code>type</code> constants for Feathers media player controls.
	 * This class is not a subclass of <code>starling.events.Event</code>
	 * because these constants are meant to be used with
	 * <code>dispatchEventWith()</code> and take advantage of the Starling's
	 * event object pooling. The object passed to an event listener will be of
	 * type <code>starling.events.Event</code>.
	 * 
	 * <listing version="3.0">
	 * function listener( event:Event ):void
	 * {
	 *     trace( mediaPlayer.currentTime );
	 * }
	 * mediaPlayer.addEventListener( MediaPlayerEventType.CURRENT_TIME_CHANGE, listener );</listing>
	 */
	public class MediaPlayerEventType
	{
		/**
		 * Dispatched when a media player changes to the full-screen display mode
		 * or back to the normal display mode.
		 */
		public static const DISPLAY_STATE_CHANGE:String = "displayStageChange";

		/**
		 * Dispatched when a media player's playback state changes, such as when
		 * it begins playing or is paused.
		 */
		public static const PLAYBACK_STATE_CHANGE:String = "playbackStageChange";
		
		/**
		 * Dispatched when a media player's total playhead time changes.
		 */
		public static const TOTAL_TIME_CHANGE:String = "totalTimeChange";
		
		/**
		 * Dispatched when a media player's current playhead time changes.
		 */
		public static const CURRENT_TIME_CHANGE:String = "currentTimeChange";

		/**
		 * Dispatched when the original, native width or height of a video
		 * player's content is calculated.
		 */
		public static const DIMENSIONS_CHANGE:String = "dimensionsChange";

		/**
		 * Dispatched periodically when a media player's content is loading to
		 * indicate the current progress.
		 */
		public static const LOAD_PROGRESS:String = "loadProgress";

		/**
		 * Dispatched when a media player's content is fully loaded and it
		 * may begin playing.
		 */
		public static const LOAD_COMPLETE:String = "loadComplete";
	}
}
