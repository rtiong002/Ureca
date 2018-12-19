//
//  SettingsFragment.swift
//  Soundapp
//
//  Created by Ryan Tiong on 14/12/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation

import android.content.SharedPreferences
import android.os.Bundle
import android.preference.PreferenceManager
import android.support.v7.preference.EditTextPreference
import android.support.v7.preference.ListPreference
import android.support.v7.preference.PreferenceFragmentCompat

// In this case, the fragment displays simple text based on the page
public class SettingsFragment : PreferenceFragmentCompat {
    
    var sharedpreferences :SharedPreferences
    var userName : EditTextPreference
    var recInterval : ListPreference
    
    public static func newInstance() -> recInterval {
        let fragment : SettingsFragment  = SettingsFragment()
        return fragment
    }
    
    override public func onCreatePreferences(bundle : Bundle , s : String) {
        addPreferencesFromResource(R.xml.preferences)
    }
    
    override public func onStart()
    {
        super.onStart()
        
        //Call your Fragment functions that uses getActivity()
        sharedpreferences = PreferenceManager.getDefaultSharedPreferences(getActivity())
        userName =  findPreference("username") as! EditTextPreference
        recInterval =  findPreference("recInterval") as! ListPreference
    }
    
    /*
     @Override
     public void onCreate(Bundle savedInstanceState) {
     super.onCreate(savedInstanceState)
     }
     
     @Override
     public View onCreateView(LayoutInflater inflater, ViewGroup container,
     Bundle savedInstanceState) {
     View view = inflater.inflate(R.layout.fragment_page, container, false)
     return view
     }
     */
}
