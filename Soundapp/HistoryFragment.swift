//
//  HistoryFragment.swift
//  Soundapp
//
//  Created by Ryan Tiong on 11/12/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation

import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.content.SharedPreferences
import android.content.SharedPreferences.Editor
import android.net.Uri
import android.os.Bundle
import android.preference.PreferenceManager
import android.support.design.widget.FloatingActionButton
import android.support.v4.app.Fragment
import android.support.v7.app.AlertDialog
import android.support.v7.widget.CardView
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

import java.lang.reflect.Type
import java.util.ArrayList
import java.util.List

public class HistoryFragment: Fragment {
    
    var sharedpreferences : SharedPreferences
    var removeAd : FloatingActionButton
    var historyEmpty : View
    var prefsEditor : Editor
    let gson = Gson()
    var adapter : AdvertisementRecycleViewAdapter
    private var ads = [Advertisement]()
    private var jsonAds : String
    private var rv : RecyclerView
    
    public class func onCreate(savedInstanceState : Bundle ) {
        super.onCreate(savedInstanceState)
        sharedpreferences = PreferenceManager.getDefaultSharedPreferences(getActivity())
        jsonAds = sharedpreferences.getString("adList", "")
        if !jsonAds.isEmpty() {
            let type = TypeToken<List<Advertisement>>() {
                }.getType()
            var newlist = [Advertisement]()
            newlist = gson.fromJson(jsonAds, type)
            ads.append(newlist)
        }
        
        let adapter = AdvertisementRecycleViewAdapter(ads, getActivity().getApplication())
        adapter.setHasStableIds(true)
    }
    
    public class func onCreateView(inflater:LayoutInflater, container : ViewGroup, savedInstanceState : Bundle) -> View{
    let view = inflater.inflate(R.layout.fragment_history, container, false)
    let rv = view.findViewById(R.id.rv) as! RecyclerView
    let llm = LinearLayoutManager(getActivity()) {
    func supportsPredictiveItemAnimations() -> boolean {
    return true
    }
    }
    rv.setLayoutManager(llm)
    rv.setHasFixedSize(true)
    
    removeAd = view.findViewById(R.id.remove_ad) as! FloatingActionButton
    removeAd.setVisibility(ads.isEmpty() ? View.GONE : View.VISIBLE)
    removeAd.setImageResource(R.drawable.ic_clear_white_36px)
    removeAd.setOnClickListener(View.OnClickListener() {
    func onClick(v : View) {
    alertDialogBuilder = AlertDialog.Builder(getActivity()) as! AlertDialog.Builder
    alertDialogBuilder
    .setTitle("Confirmation")
    .setMessage("Are you sure you want to delete all saved advertisements?")
    .setCancelable(false)
    .setPositiveButton("Yes", DialogInterface.OnClickListener() {
    func onClick(dialog : DialogInterface , id : int ) {
    // if this button is clicked, close
    // current activity
    adapter.removeAll()
    }
    })
    .setNegativeButton("No", DialogInterface.OnClickListener() {
    
    func onClick(dialog : DialogInterface , id : int ) {
    // if this button is clicked, just close
    // the dialog box and do nothing
    dialog.cancel()
    }
    })
    alertDialog = alertDialogBuilder.create() as! AlertDialog
    alertDialog.show()
    }
    })
    historyEmpty = view.findViewById(R.id.history_empty)
    historyEmpty.setVisibility(ads.isEmpty() ? View.VISIBLE : View.GONE)
    
    return view
    }
    
    
    override public func onStart() {
        super.onStart()
        rv.setAdapter(adapter)
    }
    
    override public func onStop() {
        super.onStop()
        prefsEditor = sharedpreferences.edit()
        jsonAds = gson.toJson(adapter.getAds())
        prefsEditor.putString("adList", jsonAds)
        prefsEditor.apply()
        //Log.d("TAG","jsonCars = " + jsonAds);
    }
    
    override public func insertAd(advertisement : Advertisement ) {
        adapter.insert(advertisement)
    }
    
    override private class AdvertisementRecycleViewAdapter : RecyclerView.Adapter<AdvertisementRecycleViewAdapter.AdvertisementViewHolder> {
        
        var ads = [Advertisement]()
        var context : Context
        
        init(ads:[Advertisement] , context:Context ) {
            this.ads = ads
            this.context = context
        }
        
        override public func onAttachedToRecyclerView(recyclerView : RecyclerView ) {
            super.onAttachedToRecyclerView(recyclerView)
        }
        
        override public func  onCreateViewHolder(viewGroup : ViewGroup , i : int ) -> AdvertisementViewHolder {
            let v = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.ad_card, viewGroup, false)
            return AdvertisementViewHolder(v)
        }
        
        override public func onBindViewHolder(final adViewHolder : AdvertisementViewHolder , i : int ) {
            adViewHolder.adName.setText(ads.get(i).name)
            adViewHolder.adDetails.setText(ads.get(i).details)
            //adViewHolder.adDetails.setVisibility(View.GONE);
            //adViewHolder.adSummary.setText(ads.get(i).summary);
            final var j = i
            adViewHolder.adLink.setOnClickListener(View.OnClickListener() {
                func onClick(v : View) {
                    let myWebLink = Intent(android.content.Intent.ACTION_VIEW)
                    myWebLink.setData(Uri.parse(ads.get(j).link))
                    v.getContext().startActivity(myWebLink)
                }
                })
            //adViewHolder.adImage.setImageResource(ads.get(i).imageID);
            
            /*
             final boolean isExpanded = i==mExpandedPosition;
             adViewHolder.adDetails.setVisibility(isExpanded?View.VISIBLE:View.GONE);
             adViewHolder.adSummary.setVisibility(isExpanded?View.GONE:View.VISIBLE);
             adViewHolder.itemView.setActivated(isExpanded);
             adViewHolder.itemView.setOnClickListener(new View.OnClickListener() {
             @Override
             public void onClick(View v) {
             mExpandedPosition = isExpanded ? -1:j;
             TransitionManager.beginDelayedTransition((ViewGroup)v.getParent());
             notifyDataSetChanged();
             }
             });
             */
            
            adViewHolder.adRemove.setOnClickListener(View.OnClickListener() {
                func onClick(v : View ) {
                    let alertDialogBuilder = AlertDialog.Builder(v.getContext())
                    alertDialogBuilder
                        .setTitle("Confirmation")
                        .setMessage("Are you sure you want to delete this advertisement?")
                        .setCancelable(false)
                        .setPositiveButton("Yes", DialogInterface.OnClickListener() {
                            func onClick(dialog : DialogInterface , id : int ) {
                                // if this button is clicked, close
                                // current activity
                                remove(j)
                                //removeAd.setVisibility(adapter.getAds().isEmpty()?View.GONE:View.VISIBLE);
                            }
                        })
                        .setNegativeButton("No", DialogInterface.OnClickListener() {
                            func onClick(dialog : DialogInterface , id : int ) {
                                // if this button is clicked, just close
                                // the dialog box and do nothing
                                dialog.cancel()
                            }
                        })
                    let alertDialog = alertDialogBuilder.create()
                    alertDialog.show()
                }
            })
        }
        
        private func insert(ad : Advertisement ) {
            ads.add(0, ad)
            notifyDataSetChanged()
            removeAd.setVisibility(adapter.getAds().isEmpty() ? View.GONE : View.VISIBLE)
            historyEmpty.setVisibility(ads.isEmpty() ? View.VISIBLE : View.GONE)
        }
        
        private func remove(position : int ) {
            ads.remove(position)
            notifyDataSetChanged()
            removeAd.setVisibility(adapter.getAds().isEmpty() ? View.GONE : View.VISIBLE)
            historyEmpty.setVisibility(ads.isEmpty() ? View.VISIBLE : View.GONE)
        }
        
        private func removeAll() {
            let range = ads.size()
            for i in 0..<range{
                remove(0)
            }
        }
        
        public func getAds() -> [Advertisement] {
            return ads
        }
        
        override public func getItemId(position : int ) -> long{
            return ads.get(position).hashCode()
        }
        
        override public func getItemCount() -> int {
            return ads.size()
        }
        
        public class AdvertisementViewHolder : RecyclerView.ViewHolder {
            var cv : CardView
            var adName : TextView
            var adDetails : TextView
            //TextView adSummary;
            var adLink : Button
            var adImage : ImageView
            var adRemove : Button
            
            init(itemView : View ) {
                super.init(itemView)
                cv =  itemView.findViewById(R.id.cv) as! CardView
                adName =  itemView.findViewById(R.id.ad_name) as! TextView
                adDetails = itemView.findViewById(R.id.ad_details) as! TextView
                //adSummary = (TextView)itemView.findViewById(R.id.ad_summary);
                adLink = itemView.findViewById(R.id.ad_link) as! Button
                adImage = itemView.findViewById(R.id.ad_image) as! ImageView
                adRemove = itemView.findViewById(R.id.ad_remove) as! Button
                
            }
        }
    }
}
