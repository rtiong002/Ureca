//
//  MainActivity.swift
//  Soundapp
//
//  Created by Ryan Tiong on 14/12/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation

import android.content.SharedPreferences
import android.os.Bundle
import android.support.design.widget.TabLayout
import android.support.v4.app.FragmentActivity
import android.support.v4.view.ViewPager
import android.support.v7.preference.PreferenceManager

public class MainActivity : FragmentActivity ,ListenFragment.MyInterface {
    
    var sharedpreferences : SharedPreferences
    var viewPager : ViewPagerNoSwipe
    var pagerAdapter : SampleFragmentPagerAdapter
    
    override internal func onCreate(savedInstanceState : Bundle ) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        sharedpreferences = PreferenceManager.getDefaultSharedPreferences(getApplicationContext())
        
        // Get the ViewPager and set it's PagerAdapter so that it can display items
        viewPager =  findViewById(R.id.viewpager) as! ViewPagerNoSwipe
        viewPager.setPagingEnabled(false)
        
        pagerAdapter = SampleFragmentPagerAdapter(getSupportFragmentManager(), MainActivity.this)
        viewPager.setAdapter(pagerAdapter)
        
        viewPager.addOnPageChangeListener(ViewPager.OnPageChangeListener() {
            
            override func onPageScrolled(position : int , positionOffset : float , positionOffsetPixels : int ) {
                
            }
            
            override func onPageSelected(position : int ) {
                if position != 0{
                    pagerAdapter.listenFragment.onPause()}
            }
            
            override func onPageScrollStateChanged(state : int ) {
                
            }
        })
        
        // Give the TabLayout the ViewPager
        let tabLayout : TabLayout  = findViewById(R.id.tabs) as! TabLayout
        tabLayout.setTabGravity(TabLayout.GRAVITY_FILL)
        tabLayout.setupWithViewPager(viewPager)
        
    }
    
    override public func storeAd(final advertisement : Advertisement ) {
        final var fragment : HistoryFragment  =  pagerAdapter.getItem(1) as! HistoryFragment
        runOnUiThread(Runnable() {
            override func run() {
                fragment.insertAd(advertisement)
            }
        })
    }
    
}
