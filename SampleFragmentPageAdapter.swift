//
//  SampleFragmentPageAdapter.swift
//  Soundapp
//
//  Created by Ryan Tiong on 14/12/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation

import android.content.Context
import android.support.v4.app.Fragment
import android.support.v4.app.FragmentManager
import android.support.v4.app.FragmentPagerAdapter

public class SampleFragmentPagerAdapter : FragmentPagerAdapter {
    final var PAGE_COUNT : int  = 3
    var listenFragment : ListenFragment  = ListenFragment.newInstance()
    var historyFragment : HistoryFragment  = HistoryFragment.newInstance()
    var settingsFragment : SettingsFragment  = SettingsFragment.newInstance()
    private var tabTitles  : [String] = [ "Listen", "History", "Settings" ]
    private var context : Context
    
    public init(fm : FragmentManager , context : Context ) {
        super.init(fm)
        this.context = context
    }
    
    override public func getCount() -> int {
        return PAGE_COUNT
    }
    
    
    override public func getItem(position : int ) -> Fragment{
        switch position {
        case 0:
            return listenFragment
        case 1:
            return historyFragment
        case 2:
            return settingsFragment
        default:
            return PageFragment.newInstance()
        }
    }
    
    override public func getPageTitle( position : int) -> CharSequence{
        // Generate title based on item position
        return tabTitles[position]
    }
}
