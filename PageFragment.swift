//
//  PageFragment.swift
//  Soundapp
//
//  Created by Ryan Tiong on 14/12/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation

import android.os.Bundle
import android.support.v7.preference.PreferenceFragmentCompat

// In this case, the fragment displays simple text based on the page
public class PageFragment : PreferenceFragmentCompat {
    
    public static func newInstance() -> PageFragment {
        let fragment : PageFragment  = PageFragment()
        return fragment
    }
    
    override public func onCreatePreferences(bundle : Bundle , s : String ) {
        addPreferencesFromResource(R.xml.preferences)
    }
    
    /*
     @Override
     public void onCreate(Bundle savedInstanceState) {
     super.onCreate(savedInstanceState);
     }
     
     @Override
     public View onCreateView(LayoutInflater inflater, ViewGroup container,
     Bundle savedInstanceState) {
     View view = inflater.inflate(R.layout.fragment_page, container, false);
     return view;
     }
     */
}
