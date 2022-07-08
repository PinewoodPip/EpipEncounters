package LS_Classes
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   
   public class LSPanelHelpers
   {
       
      
      public function LSPanelHelpers()
      {
         super();
      }
      
      public static function makeDraggable(param1:MovieClip) : void
      {
         var startDragDiff:uint = 0;
         var targetMC:MovieClip = param1;
         startDragDiff = 20;
         targetMC.windowDragStarted = false;
         targetMC.dragStartMP = new Point();
         targetMC.dragPanelStart = function(param1:MouseEvent):*
         {
            targetMC.windowDragStarted = false;
            targetMC.stage.addEventListener(MouseEvent.MOUSE_MOVE,targetMC.dragPanelMove);
            targetMC.dragStartMP.y = targetMC.stage.mouseY;
            targetMC.dragStartMP.x = targetMC.stage.mouseX;
            targetMC.stage.addEventListener(MouseEvent.MOUSE_UP,targetMC.dragPanelStop);
         };
         targetMC.dragPanelMove = function(param1:MouseEvent):*
         {
            if(targetMC.dragStartMP.x + startDragDiff > targetMC.stage.mouseX || targetMC.dragStartMP.y + startDragDiff > targetMC.stage.mouseY || targetMC.dragStartMP.x - startDragDiff < targetMC.stage.mouseX || targetMC.dragStartMP.y - startDragDiff < targetMC.stage.mouseY)
            {
               targetMC.stage.focus = null;
               ExternalInterface.call("hideTooltip");
               ExternalInterface.call("startMoveWindow");
               targetMC.stage.removeEventListener(MouseEvent.MOUSE_MOVE,targetMC.dragPanelMove);
               targetMC.windowDragStarted = true;
            }
         };
         targetMC.dragPanelStop = function(param1:MouseEvent):*
         {
            if(targetMC.windowDragStarted)
            {
               ExternalInterface.call("cancelMoveWindow");
            }
            else
            {
               targetMC.stage.removeEventListener(MouseEvent.MOUSE_MOVE,targetMC.dragPanelMove);
            }
            targetMC.stage.removeEventListener(MouseEvent.MOUSE_UP,targetMC.dragPanelStop);
            targetMC.windowDragStarted = false;
         };
         targetMC.addEventListener(MouseEvent.MOUSE_DOWN,targetMC.dragPanelStart);
      }
   }
}
