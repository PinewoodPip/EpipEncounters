public function slotHolder.onCheckSlotsOver(param1:MouseEvent) : *
{
    var _loc3_:MovieClip = null;
    var _loc2_:Number = this.getSlotOnXY(mouseX,mouseY);
    if(this.currentHLSlot != _loc2_)
    {
    this.clearCurrentHL();
    this.currentHLSlot = _loc2_;
    _loc3_ = this.getSlot(this.currentHLSlot);
    if(_loc3_)
    {
        _loc3_.onMouseOver();
        this.showSlotMCTooltip(_loc3_);
        if(_loc3_.isEnabled && _loc3_.inUse || this.base.isDragging)
        {
            this.sel_mc.hl_mc.alpha = 0;
            this.sel_mc.hl_mc.x = _loc3_.x;
            this.sel_mc.hl_mc.y = _loc3_.y;
            this.sel_mc.hl_mc.visible = true;
            if(this.timeline)
            {
                this.timeline.stop();
            }
            this.timeline = new larTween(this.sel_mc.hl_mc,"alpha",Cubic.easeOut,NaN,0.3,0.2);
        }
    }
    }
}

public function slotHolder.showActiveSkill(param1:Number) : *
{
    var _loc2_:MovieClip = this.getSlot(param1);
    if(_loc2_)
    {
    this.activeSkill_mc.x = _loc2_.x + 25;
    this.activeSkill_mc.y = _loc2_.y + 25;
    this.activeSkill_mc.visible = true;
    this.activeSkill_mc.play();
    this.activeSkillBarNr = this.base.currentBar;
    this.activeSkillSlotNr = param1;
    }
    else
    {
    this.activeSkill_mc.visible = false;
    this.activeSkill_mc.stop();
    this.activeSkillBarNr = -1;
    this.activeSkillSlotNr = -1;
    }
}

// go to 2 if diminishing below 1
// go to 1 if scrolling past 2
public function cycleHotBar(param1:Array) : *
    {
        var _loc2_:* = param1[0];
        if(_loc2_ && this.currentHotBarIndex > 1)
        {
            --this.currentHotBarIndex;
            if(this.currentHotBarIndex < 1)
            {
                this.currentHotBarIndex = 2;
                ExternalInterface.call("nextHotbar");
            }
            else
            {
                ExternalInterface.call("prevHotbar");
            }
            this.text_txt.htmlText = String(this.currentHotBarIndex);
        }
        else if(this.currentHotBarIndex < 3)
        {
            ++this.currentHotBarIndex;
            if(this.currentHotBarIndex > 2)
            {
                this.currentHotBarIndex = 1;
                ExternalInterface.call("prevHotbar");
            }
            else
            {
                ExternalInterface.call("nextHotbar");
            }
            this.text_txt.htmlText = String(this.currentHotBarIndex);
        }
    }

 public function hotbarbrowser.cycleHotBar(param1:Array) : *
      {
         var _loc2_:* = param1[0];
         if(_loc2_)
         {
            ExternalInterface.call("pipPrevHotbar", this.currentHotBarIndex);
         }
         else
         {
            ExternalInterface.call("pipNextHotbar", this.currentHotBarIndex);
         }
      }

public function getSlotOnXY(param1:Number, param2:Number) : Number
      {
         var _loc3_:int = int(param1 / (this.cellWidth + this.cellSpacing));
         if(param2 < 0)
         {
            _loc3_ += this.rowOrder_array(Math.floor(param2 / this.rowHeight)) * -29;
         }
         else
         {
            _loc3_ += this.rowOrder_array[0] * -29;   
         }
         if(param1 > (this.cellWidth + this.cellSpacing) * _loc3_ + this.cellWidth)
         {
            _loc3_ = -1;
         }
         return _loc3_;
      }