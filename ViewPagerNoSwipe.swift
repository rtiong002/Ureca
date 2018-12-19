//
//  ViewPagerNoSwipe.swift
//  Soundapp
//
//  Created by Ryan Tiong on 14/12/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation

import android.content.Context
import android.support.v4.view.ViewPager
import android.util.AttributeSet
import android.view.MotionEvent

public class ViewPagerNoSwipe :ViewPager {
    
    private var enabled : boolean
    
    public init(context : Context , attrs : AttributeSet ) {
        super.init(context, attrs)
        this.enabled = true
    }
    
    override public  func onTouchEvent(event : MotionEvent ) -> boolean{
        if this.enabled {
            return super.onTouchEvent(event)
        }
        
        return false
    }
    
    override public func onInterceptTouchEvent(event : MotionEvent ) ->  boolean {
        if this.enabled {
            return super.onInterceptTouchEvent(event)
        }
        
        return false
    }
    
    override public func setCurrentItem(item : int , smoothScroll : boolean ) {
        super.setCurrentItem(item, false)
    }
    
    override public func setCurrentItem(item : int ) {
        super.setCurrentItem(item, false)
    }
    
    public func setPagingEnabled( enabled : boolean) {
        this.enabled = enabled
    }
    
}
