//
//  Listenfragment.swift
//  Soundapp
//
//  Created by Ryan Tiong on 13/12/18.
//  Copyright © 2018 Ryan Tiong. All rights reserved.
//

import Foundation

import android.Manifest
import android.content.Context
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.database.Cursor
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Bundle
import android.os.Environment
import android.preference.PreferenceManager
import android.support.design.widget.FloatingActionButton
import android.support.v4.app.ActivityCompat
import android.support.v4.app.Fragment
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView
import java.io.DataInputStream
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.ArrayList
import java.util.List
import java.util.Timer
import java.util.TimerTask

public class ListenFragment : Fragment {
    
    private static final var RECORDER_SAMPLERATE : int = 44100
    private static final var RECORDER_CHANNELS : int  = AudioFormat.CHANNEL_IN_MONO
    private static final var RECORDER_AUDIO_ENCODING : int  = AudioFormat.ENCODING_PCM_16BIT
    private static var BUFFER_SIZE : int  = AudioRecord.getMinBufferSize(
        RECORDER_SAMPLERATE, RECORDER_CHANNELS, RECORDER_AUDIO_ENCODING)
    private static var recordInterval : int
    private static var cycleLimit : int
    var sharedpreferences : SharedPreferences
    private var cycleCount : int
    private var audio : [short]
    private var text : TextView
    private var placeholder : LinearLayout
    private var mRecordButton : FloatingActionButton  = null
    private var recorder : AudioRecord  = null
    private var recordingThread : Thread  = null
    private var isRecording : boolean  = false
    private var recordTask : TimerTask
    private var recordRunnable : RecordRunnable
    private var listener : MyInterface
    
    public static func newInstance() -> ListenFragment {
        return ListenFragment()
    }
    
    private func onRecord(isRecording : boolean ) {
        if !isRecording {
            AudioMatching.reset(DBHelper(getContext()))
            cycleCount = 0
            startRecording()
            mRecordButton.setImageResource(R.drawable.ic_stop_white_36px)
            mRecordButton.setSoundEffectsEnabled(true)
            placeholder.removeAllViews()
            text.setText("Click on the button to stop recording")
            placeholder.addView(text)
        } else {
            stopRecording()
            mRecordButton.setImageResource(R.drawable.ic_hearing_white_36px)
            mRecordButton.setSoundEffectsEnabled(false)
            placeholder.removeAllViews()
            text.setText("Click on the button to start recording")
            placeholder.addView(text)
        }
    }
    
    private func startRecording() {
        recorder.startRecording()
        isRecording = true
        recordRunnable = RecordRunnable()
        recordingThread = Thread(recordRunnable, "AudioRecorder Thread")
        recordingThread.start()
        recordTask = RecordTask()
        let timer : Timer  = Timer()
        timer.schedule(recordTask, recordInterval * 1000)
    }
    
    private func stopRecording() {
        if recorder != null && recordRunnable != null {
            recordTask.cancel()
            recordRunnable.stop()
            recordRunnable = null
            recordingThread = null
            recorder.stop()
            isRecording = false
        }
    }
    
    override public func onCreate(savedInstanceState : Bundle ) {
        super.onCreate(savedInstanceState)
    }
    
    override public func onCreateView(inflater : LayoutInflater , container : ViewGroup ,
                                      savedInstanceState : Bundle ) -> View {
        let view : View  = inflater.inflate(R.layout.fragment_listen, container, false)
        
        placeholder =  view.findViewById(R.id.placeholder) as! LinearLayout
        placeholder.setOrientation(LinearLayout.VERTICAL)
        text = TextView(getContext())
        text.setGravity(Gravity.CENTER)
        text.setText("Click on the button to start recording")
        placeholder.addView(text)
        
        mRecordButton =  view.findViewById(R.id.start_record) as! FloatingActionButton
        mRecordButton.setImageResource(R.drawable.ic_hearing_white_36px)
        mRecordButton.setSoundEffectsEnabled(false)
        
        mRecordButton.setOnClickListener(View.OnClickListener() {
            func onClick(v : View ) {
                if ActivityCompat.checkSelfPermission(getActivity(), Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED || ActivityCompat.checkSelfPermission(getActivity(), Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED{
                    ActivityCompat.requestPermissions(getActivity(), [String]=[Manifest.permission.RECORD_AUDIO, Manifest.permission.WRITE_EXTERNAL_STORAGE],0)}
                else{
                    onRecord(isRecording)}
            }
        })
        
        return view
    }
    
    override public func onStart() {
        super.onStart()
        sharedpreferences = PreferenceManager.getDefaultSharedPreferences(getActivity())
        recordInterval = Integer.parseInt(sharedpreferences.getString("recInterval", "2"))
        cycleLimit = Integer.parseInt(sharedpreferences.getString("cycleLimit", "10"))
        audio = short[RECORDER_SAMPLERATE * recordInterval]
        recorder = AudioRecord(MediaRecorder.AudioSource.MIC, RECORDER_SAMPLERATE, RECORDER_CHANNELS, RECORDER_AUDIO_ENCODING, BUFFER_SIZE)
        // Renew database upon AudioAnalysis parameters change
        /*
         DBHelper dbHelper = new DBHelper(getContext())
         dbHelper.refreshDatabase()
         dbHelper.insertAd("Holcim", "Contact Details\n" +
         "\n" +
         "Address    -  Hagenholzstrasse 85\n" +
         "              CH - 8050 Zurich\n" +
         "              Switzerland.\n" +
         "\n" +
         "Phone      -  +41 58 858 5858\n" +
         "Fax        -  +41 58 858 5859", "http://www.holcim.com", R.drawable.test, 0)
         dbHelper.insertAd("Hutch", "Contact Details\n" +
         "\n" +
         "Address             -  Hutchison Telecommunications\n" +
         "\t\t       Lanka (Pvt) Ltd,\n" +
         "                       234, Galle Road, Colombo 04, \n" +
         "                       Sri Lanka.\n" +
         "\n" +
         "Telephone Number    -  1788\n" +
         "Send SMS            -  5555 \n" +
         "Email               -  cs@hutchison.lk", "https://www.hutch.lk", R.drawable.test, 1)
         dbHelper.insertAd("Hutch", "Contact Details\n" +
         "\n" +
         "Address             -  Hutchison Telecommunications\n" +
         "\t\t       Lanka (Pvt) Ltd,\n" +
         "                       234, Galle Road, Colombo 04, \n" +
         "                       Sri Lanka.\n" +
         "\n" +
         "Telephone Number    -  1788\n" +
         "Send SMS            -  5555 \n" +
         "Email               -  cs@hutchison.lk", "https://www.hutch.lk", R.drawable.test, 2)
         dbHelper.insertAd("Janet", "Contact Details\n" +
         "\n" +
         "Address -   The Janet Group.\n" +
         "            Level #1\n" +
         "            No 269, Galle Road,\n" +
         "            Mount Lavinia.\n" +
         "\n" +
         "Sri Lanka Tel - +94 114 200022\n" +
         "Fax           - +94 114 200024\n" +
         "E-mail        - info@janet-ayurveda.com\n" +
         "\n" +
         "Janet Salons\n" +
         "\n" +
         "1. No. 3, Castle Avenue, Colombo 8.\n" +
         "2. No. 15, Sinsapa Road, Colombo 6.\n" +
         "3. Keells Super Building, No. 126 B , Highlevel Road, Nugegoda.", "http://janet-ayurveda.com/", R.drawable.test, 3)
         dbHelper.insertAd("Janet", "Contact Details\n" +
         "\n" +
         "Address -   The Janet Group.\n" +
         "            Level #1\n" +
         "            No 269, Galle Road,\n" +
         "            Mount Lavinia.\n" +
         "\n" +
         "Sri Lanka Tel - +94 114 200022\n" +
         "Fax           - +94 114 200024\n" +
         "E-mail        - info@janet-ayurveda.com\n" +
         "\n" +
         "Janet Salons\n" +
         "\n" +
         "1. No. 3, Castle Avenue, Colombo 8.\n" +
         "2. No. 15, Sinsapa Road, Colombo 6.\n" +
         "3. Keells Super Building, No. 126 B , Highlevel Road, Nugegoda.", "http://janet-ayurveda.com/", R.drawable.test, 4)
         dbHelper.insertAd("Keells Super", "Contact Details \n" +
         "\n" +
         "\"John Keells Holdings PLC\"\n" +
         "\n" +
         "Jaykay Marketing Services Pvt Ltd.\n" +
         "No:148, Vauxhall Street,\n" +
         "Colombo 2, Sri Lanka.\n" +
         "\n" +
         "Telephone No.     - +94 11 2303500 \n" +
         "Text (SMS) 'Operations'  - +94 77 3762524 \n" +
         "Text (SMS) 'Technical'   - +94 77 3647586 Fax: +94 11 2303555\n" +
         "\n" +
         "\n" +
         "Email\n" +
         "Delivery Operations      - ksoperations.jms@keells.com\n" +
         "Technical                - web.jms@keells.com", "https://www.keellssuper.com", R.drawable.test, 5)
         dbHelper.insertAd("Keells Super", "Contact Details \n" +
         "\n" +
         "\"John Keells Holdings PLC\"\n" +
         "\n" +
         "Jaykay Marketing Services Pvt Ltd.\n" +
         "No:148, Vauxhall Street,\n" +
         "Colombo 2, Sri Lanka.\n" +
         "\n" +
         "Telephone No.     - +94 11 2303500 \n" +
         "Text (SMS) 'Operations'  - +94 77 3762524 \n" +
         "Text (SMS) 'Technical'   - +94 77 3647586 Fax: +94 11 2303555\n" +
         "\n" +
         "\n" +
         "Email\n" +
         "Delivery Operations      - ksoperations.jms@keells.com\n" +
         "Technical                - web.jms@keells.com", "https://www.keellssuper.com", R.drawable.test, 6)
         dbHelper.insertAd("Keells Super", "Contact Details \n" +
         "\n" +
         "\"John Keells Holdings PLC\"\n" +
         "\n" +
         "Jaykay Marketing Services Pvt Ltd.\n" +
         "No:148, Vauxhall Street,\n" +
         "Colombo 2, Sri Lanka.\n" +
         "\n" +
         "Telephone No.     - +94 11 2303500 \n" +
         "Text (SMS) 'Operations'  - +94 77 3762524 \n" +
         "Text (SMS) 'Technical'   - +94 77 3647586 Fax: +94 11 2303555\n" +
         "\n" +
         "\n" +
         "Email\n" +
         "Delivery Operations      - ksoperations.jms@keells.com\n" +
         "Technical                - web.jms@keells.com", "https://www.keellssuper.com", R.drawable.test, 7)
         dbHelper.insertAd("Keells Super", "Contact Details \n" +
         "\n" +
         "\"John Keells Holdings PLC\"\n" +
         "\n" +
         "Jaykay Marketing Services Pvt Ltd.\n" +
         "No:148, Vauxhall Street,\n" +
         "Colombo 2, Sri Lanka.\n" +
         "\n" +
         "Telephone No.     - +94 11 2303500 \n" +
         "Text (SMS) 'Operations'  - +94 77 3762524 \n" +
         "Text (SMS) 'Technical'   - +94 77 3647586 Fax: +94 11 2303555\n" +
         "\n" +
         "\n" +
         "Email\n" +
         "Delivery Operations      - ksoperations.jms@keells.com\n" +
         "Technical                - web.jms@keells.com", "https://www.keellssuper.com", R.drawable.test, 8)
         dbHelper.insertAd("Keells Super", "Contact Details \n" +
         "\n" +
         "\"John Keells Holdings PLC\"\n" +
         "\n" +
         "Jaykay Marketing Services Pvt Ltd.\n" +
         "No:148, Vauxhall Street,\n" +
         "Colombo 2, Sri Lanka.\n" +
         "\n" +
         "Telephone No.     - +94 11 2303500 \n" +
         "Text (SMS) 'Operations'  - +94 77 3762524 \n" +
         "Text (SMS) 'Technical'   - +94 77 3647586 Fax: +94 11 2303555\n" +
         "\n" +
         "\n" +
         "Email\n" +
         "Delivery Operations      - ksoperations.jms@keells.com\n" +
         "Technical                - web.jms@keells.com", "https://www.keellssuper.com", R.drawable.test, 9)
         
         String[] files = {"holcim.wav", "hutch1.wav", "hutch2.wav", "janet1.wav", "janet2.wav", "keells1.wav", "keells2.wav", "keells3.wav", "keells4.wav", "keells5.wav"}
         for (int i = 0 i < files.length i++) {
         String fileNames = files[i]
         File file = new File(Environment.getExternalStorageDirectory().getAbsolutePath() + "/" + fileNames)
         byte[] imgDataBa = new byte[(int) file.length()]
         
         DataInputStream dataIs
         try {
         dataIs = new DataInputStream(new FileInputStream(file))
         dataIs.readFully(imgDataBa)
         } catch (IOException e) {
         e.printStackTrace()
         }
         
         short[] shorts = new short[imgDataBa.length / 2]
         // to turn bytes to shorts as either big endian or little endian.
         ByteBuffer.wrap(imgDataBa).order(ByteOrder.LITTLE_ENDIAN).asShortBuffer().get(shorts)
         
         ArrayList<int[]> peaks = AudioAnalysis.analyze(shorts)
         ArrayList<Fingerprint> fingerprints = AudioHashing.hash(peaks)
         
         for (Fingerprint f : fingerprints)
         dbHelper.insertFingerprint(f.getAnchorFrequency(), f.getPointFrequency(), f.getDelta(), f.getAbsoluteTime(), i)
         
         }
         dbHelper.close()
         */
    }
    
    override public func onPause() {
        super.onPause()
        if isRecording {
            onRecord(true)
        }
    }
    
    override public func onAttach( context : Context) {
        super.onAttach(context)
        if (context is MyInterface) {
            listener = context as! MyInterface
        }
    }
    
    override public func onDetach() {
        listener = null
        super.onDetach()
    }
    
    override public protocol MyInterface {
        func storeAd(advertisement : Advertisement )
    }
    
    private class RecordTask : TimerTask {
        public func run() {
            if recorder != null {
                stopRecording()
                let peaks : ArrayList<[int]> = AudioAnalysis.analyze(audio)
                let fingerprints : ArrayList<Fingerprint> = AudioHashing.hash(peaks)
                audio = hort[RECORDER_SAMPLERATE * recordInterval]
                startRecording()
                let match : [int]  = AudioMatching.match(fingerprints, DBHelper(getContext()))
                if match != null && isRecording {
                    if match[1] > 10 {
                        let displayAndStoreAdRunnable : DisplayAndStoreAdRunnable  = DisplayAndStoreAdRunnable()
                        displayAndStoreAdRunnable.setMatch(match[0])
                        displayAndStoreAdRunnable.run()
                    }
                }
                if cycleCount > cycleLimit {
                    getActivity().runOnUiThread(Runnable() {
                        func run() {
                            onRecord(true)
                            placeholder.removeAllViews()
                            text.setText("No match found!" + "\n\n" + "Click on the button to start again")
                            placeholder.addView(text)
                        }
                    })
                }
                cycleCount++
            }
        }
    }
    
    private class RecordRunnable : Runnable {
        private /*volatile*/ var isStopped : boolean = false
        
        public func run() {
            if !isStopped {
                let sData : [short] = short[BUFFER_SIZE / 2]
                let index : short = 0
                while isRecording {
                    recorder.read(sData, 0, BUFFER_SIZE / 2)
                    if index + sData.length <= audio.length {
                        System.arraycopy(sData, 0, audio, index, sData.length)
                        index += sData.length
                    }
                }
            }
        }
        
        func stop() {
            isStopped = true
        }
    }
    
    private class DisplayAndStoreAdRunnable : Runnable {
        var match : int  = -1
        var name : String
        var details : String
        var link : String
        var imageID : int
        
        override public func run() {
            let dbHelper : DBHelper  = DBHelper(getContext())
            final let  adDetails : Cursor  = dbHelper.getAdDetails(match)
            if adDetails.moveToFirst() {
                name = adDetails.getString(adDetails.getColumnIndex("name"))
                details = adDetails.getString(adDetails.getColumnIndex("details"))
                link = adDetails.getString(adDetails.getColumnIndex("link"))
                imageID = adDetails.getInt(adDetails.getColumnIndex("image_id"))
            }
            adDetails.close()
            dbHelper.close()
            final  let advertisement :  Advertisement  = Advertisement(name, details, link, imageID, match)
            listener.storeAd(advertisement)
            getActivity().runOnUiThread(Runnable() {
                override func run() {
                    onRecord(true)
                    placeholder.removeAllViews()
                    let header : TextView  = TextView(getContext())
                    header.setGravity(Gravity.CENTER)
                    header.setText("Match found!")
                    placeholder.addView(header)
                    let matchingAd : List<Advertisement>  = ArrayList<>()
                    matchingAd.add(advertisement)
                    let matchingAdDisplay : RecyclerView = RecyclerView(getContext())
                    matchingAdDisplay.setLayoutManager(LinearLayoutManager(getContext()))
                    matchingAdDisplay.setHasFixedSize(true)
                    let matchingAdDisplayAdapter  : AdvertisementRecycleViewAdapter = AdvertisementRecycleViewAdapter(matchingAd, getContext())
                    matchingAdDisplay.setAdapter(matchingAdDisplayAdapter)
                    placeholder.addView(matchingAdDisplay)
                    let footer : TextView  = TextView(getContext())
                    footer.setGravity(Gravity.CENTER)
                    footer.setText("Click on the button to start recording")
                    placeholder.addView(footer)
                }
            })
        }
        
        public func setMatch(match : int ) {
            this.match = match
        }
    }
}
