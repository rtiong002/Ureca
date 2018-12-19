//
//  AdvertisementRecycleViewAdapter.swift
//  Soundapp
//
//  Created by Ryan Tiong on 13/12/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation

import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.net.Uri
import android.support.v7.app.AlertDialog
import android.support.v7.widget.CardView
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView


public class AdvertisementRecycleViewAdapter:RecyclerView.Adapter<AdvertisementRecycleViewAdapter.AdvertisementViewHolder> {
    var ads:[Advertisement]
    var context:Context
    
    func AdvertisementRecycleViewAdapter(ads:[Advertisement] , context:Context) {
        self.ads = ads
        self.context = context
    }

    override func onAttachedToRecyclerView(recyclerView:RecyclerView) {
        super.onAttachedToRecyclerView(recyclerView)
    }

    override func onCreateViewHolder(viewGroup:ViewGroup, i:Int) -> AdvertisementViewHolder {
        var v:View = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.ad_card, viewGroup, false)
        var avh:AdvertisementViewHolder = AdvertisementViewHolder(v)
        return avh
    }
    
    override public func onBindViewHolder(final adViewHolder:AdvertisementViewHolder, i:Int) {
            adViewHolder.adName.setText(ads.get(i).name)
            adViewHolder.adDetails.setText(ads.get(i).details)
            final var j:Int = i
            adViewHolder.adLink.setOnClickListener(View.OnClickListener() {
                func onClick(v:View) {
                    var myWebLink:Intent = Intent(android.content.Intent.ACTION_VIEW)
                    myWebLink.setData(Uri.parse(ads.get(j).link))
                    v.getContext().startActivity(myWebLink)
                }
            })
            adViewHolder.adImage.setImageResource(ads.get(i).imageID)
        
            adViewHolder.adRemove.setOnClickListener(View.OnClickListener() {
                func onClick(v:View) {
                var alertDialogBuilder:AlertDialog.Builder = AlertDialog.Builder(v.getContext())
                // set title
                alertDialogBuilder.setTitle("Confirmation")
            
                // set dialog message
                alertDialogBuilder.setMessage("Are you sure you want to delete this advertisement?")
                .setCancelable(false)
                .setPositiveButton("Yes", DialogInterface.OnClickListener() {
                    func onClick(dialog:DialogInterface, id:Int) {
                        // if this button is clicked, close
                        // current activity
                        remove(j)
                        //removeAd.setVisibility(adapter.getAds().isEmpty()?View.GONE:View.VISIBLE);
                    }
                })
                .setNegativeButton("No", DialogInterface.OnClickListener() {
                    func onClick(dialog:DialogInterface, id:Int) {
                        // if this button is clicked, just close
                        // the dialog box and do nothing
                        dialog.cancel()
                    }
                })
            
                    // create alert dialog
                    var alertDialog:AlertDialog = alertDialogBuilder.create()
            
                    // show it
                    alertDialog.show()
                }
            })
        }
    func insert(position:Int, ad:Advertisement ) {
        ads.add(position, ad)
        notifyDataSetChanged()
    }
    
    func remove(position:Int) {
        ads.remove(position)
        notifyDataSetChanged()
    }
    
    func removeAll() {
        var range:Int = ads.size();
        for i in range {
            remove(0)
        }
    }
    
    func getAds() -> [Advertisement]{
        return ads
    }
    
    override public func getItemId(position:Int) -> long {
        return ads.get(position).hashCode()
    }
    
    override public func getItemCount() -> Int {
        return ads.size()
    }
    
    public class AdvertisementViewHolder: RecyclerView.ViewHolder {
        var cv:CardView
        var adName:TextView
        var adDetails:TextView
        //TextView adSummary;
        var adLink:Button
        var adImage:ImageView
        var adRemove:Button
    
        init (itemView:View) {
            super.init(itemView)
            var cv = itemView.findViewById(R.id.cv) as! CardView
            var adName = itemView.findViewById(R.id.ad_name) as! TextView
            var adDetails = itemView.findViewById(R.id.ad_details) as! TextView
            //adSummary = (TextView)itemView.findViewById(R.id.ad_summary);
            var adLink = itemView.findViewById(R.id.ad_link) as! Button
            var adImage = itemView.findViewById(R.id.ad_image) as! ImageView
            var adRemove = itemView.findViewById(R.id.ad_remove) as! Button
        }
    }
}
