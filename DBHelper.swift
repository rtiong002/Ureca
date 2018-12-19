//
//  DBHelper.swift
//  Soundapp
//
//  Created by Ryan Tiong on 13/12/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation

import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.DatabaseUtils
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

public class DBHelper:SQLiteOpenHelper {
    
    init(context : Context ) {
        super.init(context, "FingerprintDatabase.db", null, 1)
    }
    
    override public func onCreate(db : SQLiteDatabase ) {
        // TODO Auto-generated method stub
        db.execSQL(
            "create table if not exists ads " +
            "(name varchar(50), details varchar(65535), link varchar(100), image_id int, ad_id int, primary key (ad_id))"
        )
        db.execSQL(
            "create table if not exists fingerprints " +
            "(anchor_frequency smallint, point_frequency smallint, delta smallint, absolute_time smallint, ad_id int, foreign key (ad_id) references ads(ad_id))"
        )
    }
    
    override public func onUpgrade(db:SQLiteDatabase , oldVersion:int , newVersion:int ) {
        // TODO Auto-generated method stub
        db.execSQL("DROP TABLE IF EXISTS fingerprints")
        db.execSQL("DROP TABLE IF EXISTS ads")
        onCreate(db)
    }
    
    public func refreshDatabase() {
        let db : SQLiteDatabase  = this.getWritableDatabase()
        db.execSQL("DROP TABLE IF EXISTS fingerprints")
        db.execSQL("DROP TABLE IF EXISTS ads")
        onCreate(db)
    }
    
    public func insertFingerprint(anchorFrequency : short, pointFrequency : short , delta : byte ,absoluteTime : short , adID : int ) -> boolean {
        let db : SQLiteDatabase  = this.getWritableDatabase()
        let contentValues : ContentValues  = ContentValues()
        contentValues.put("anchor_frequency", anchorFrequency)
        contentValues.put("point_frequency", pointFrequency)
        contentValues.put("delta", delta)
        contentValues.put("absolute_time", absoluteTime)
        contentValues.put("ad_id", adID)
        db.insert("fingerprints", null, contentValues)
        return true
    }
    
    public func insertAd(name : String ,details :  String ,  link : String, imageID : int , adID : int ) -> boolean {
        let db : SQLiteDatabase  = this.getWritableDatabase()
        let contentValues : ContentValues  = ContentValues()
        contentValues.put("name", name)
        contentValues.put("details", details)
        contentValues.put("link", link)
        contentValues.put("image_id", imageID)
        contentValues.put("ad_id", adID)
        db.insert("ads", null, contentValues)
        return true
    }
    
    public func getFingerprintCouples(anchorFrequency : short ,pointFrequency : short , delta : byte ) -> Cursor {
        let db : SQLiteDatabase = this.getReadableDatabase()
        let res : Cursor = db.rawQuery("select absolute_time, ad_id from fingerprints " +
            "where anchor_frequency=" + anchorFrequency + " and point_frequency=" + pointFrequency + " and delta=" + delta, null)
        return res
    }
    
    public func getAdDetails(adID : int ) -> Cursor {
        let db : SQLiteDatabase  = this.getReadableDatabase()
        let res : Cursor = db.rawQuery("select name, details, link, image_id from ads " +
            "where ad_id=" + adID, null)
        return res
    }
    
    public func getNumOfAds() -> long {
        let db : SQLiteDatabase  = this.getReadableDatabase()
        let numRows : long  = DatabaseUtils.queryNumEntries(db, "ads")
        return numRows
    }
    
    /*
     public ArrayList<String> getAllCotacts() {
     ArrayList<String> array_list = new ArrayList<String>()
     
     //hp = new HashMap()
     SQLiteDatabase db = this.getReadableDatabase()
     Cursor res =  db.rawQuery( "select * from contacts", null )
     res.moveToFirst()
     
     while(res.isAfterLast() == false){
     array_list.add(res.getString(res.getColumnIndex(CONTACTS_COLUMN_NAME)))
     res.moveToNext()
     }
     return array_list
     }
     */
}
