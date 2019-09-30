/*
 * Filename: /Users/01258409/Documents/css-hmto-01258409/src/reactSrc/contents/other/demo/DemoPage.tsx
 * Path: /Users/01258409/Documents/css-hmto-01258409
 * Created Date: Tuesday, May 22nd 2018, 10:30:46 am
 * Author: 01258409
 *
 * Copyright (c) 2018 Your Company
 */

import * as React from "react";

import {
  requireNativeComponent,
  DeviceEventEmitter,
  View,
  Text,
  StyleSheet,
  Button,
  ProgressBarAndroid,
  FlatList,
  TextInput,
  NativeModules
} from "react-native";
import BluetoothSerialExample from "../bluetooth/Bluetooth";
// import { BluetoothSerial } from "react-native-bluetooth-serial";
import { IDSS_ACTION } from "../../../common/constants/TakeConstantsStr";
export const RNDDScan = requireNativeComponent("DDScanView");
import ImagePicker from 'react-native-image-picker';

var RNPushNotification = NativeModules.RNPushNotification;

interface IDemoPageProps {
  backBefore: () => void;
}
enum ComponentView {
  DDSCAN,
  BLUE_TOOTH,
  START_PAGE_RESULT
}

class DemoPage extends React.PureComponent<IDemoPageProps> {
  constructor(props: IDemoPageProps) {
    super(props);
    this.scanResult = this.scanResult.bind(this);
    this.state = {
      resultCode: "100000",
      changeView: ComponentView.START_PAGE_RESULT,
      text: ""
    };
  }

  //2，回调函数
  scanResult(e: Event): void {
    // handle event.
    console.log(e);
    this.setState({
      resultCode: e.result
    });
  }
  componentWillMount() {}
  //3，注册监听

  componentDidMount() {
    DeviceEventEmitter.addListener("onScanResult", this.scanResult);
  }

  //4，注销监听
  componentWillUnmount() {
    // When you want to stop listening to new events, simply call .remove() on the subscription
    DeviceEventEmitter.removeListener("onScanResult", this.scanResult);
  }
  static navigationOptions = (headerProps: any) => {
    return {
      header: null
    };
  };

  // render() {
  // return <DemoView {...this.props} />;

  // }
  render() {
    let needChangeView = (
      <View>
        <Text>ssssss</Text>
      </View>
    );
    console.log("render");
    switch (this.state.changeView) {
      case ComponentView.DDSCAN:
        needChangeView = (
          <RNDDScan
            style={{
              flex: 1
            }}
            onDDScanBarCodeRead={(event: { data: string }) => {
              console.log(event.nativeEvent.data);
              this.setState({ text: event.nativeEvent.data });
            }}
          />
        );
        break;
      case ComponentView.BLUE_TOOTH:
        needChangeView = (
          // <View style={styles.bluetoothLayout} >
          // <Button title="list" onPress={()=>{
          //   BT.on("bluetoothEnabled",()=>{

          //   });
          // }}></Button>
          // </View>
          <BluetoothSerialExample {...this.props} />
        );
        break;
      case ComponentView.START_PAGE_RESULT:
        needChangeView = <View />;
        break;
    }

    return (
      <View
        style={{
          flex: 1
        }}
      >
        {needChangeView}
        <View style={styles.coverlayout}>
          <Text>上层布局模拟</Text>
          <Text>上层布局模拟</Text>

          <TextInput
            style={{ height: 40, borderColor: "gray", borderWidth: 1 }}
            onChangeText={text => {
              this.setState({ text });
              console.log(text);
            }}
            value={this.state.text}
          />
          <View style={styles.continer}>
            <ProgressBarAndroid />
            <ProgressBarAndroid styleAttr="Horizontal" />
            <ProgressBarAndroid styleAttr="Horizontal" color="#2196F3" />
            <ProgressBarAndroid
              styleAttr="Horizontal"
              indeterminate={false}
              progress={0.5}
            />
            <Button
              title="启动页面获取值"
              onPress={() => {
                NativeModules.StartPageForResultModule.startPageForResult(
                  IDSS_ACTION,
                  10086,
                  {
                    openBoxPicType: "0",
                    openBoxPicture: true,
                    emuInfo:
                      '{"batchPickup":false,"cardType":"","code":"SF","deliveryAddress":"广东省深圳市福田区华强北燕南路桑达小区404栋","deliveryCity":"755","deliveryContName":"TPP梁静","deliveryMobile":"18825364445","deliveryPhone":"18825364445","identifyKey":"","networkInfo":"020A","pickupAddress":"深圳市福田区华强北桑达工业区404栋东侧","pickupContact":"李默","pickupEmp":"801172","pickupMobile":"18825364445","shipperCity":"020","waybillNo":"755841110631"}',
                    validate_type_identity_card: false,
                    idCardSHA: "",
                    sfEmpName: "801172"
                  }
                ).then((result: Object) => {
                  console.log("result : " + result);
                });
              }}
            />

            {/* <FlatList style={{
        height:200
      }}
        data={[{key: 'a'}, {key: 'b'},
        {key: 'a'}, {key: 'b'},
        {key: 'a'}, {key: 'b'},
        {key: 'a'}, {key: 'b'},
        {key: 'a'}, {key: 'b'},
        {key: 'a'}, {key: 'b'},
        {key: 'a'}, {key: 'b'},
        {key: 'a'}, {key: 'b'},
        {key: 'a'}, {key: 'b'},
        {key: 'a'}, {key: 'b'},
        {key: 'a'}, {key: 'b'}]}
        renderItem={({item}) => <Text>{item.key}</Text>}
      /> */}
          </View>
          <Text style={styles.text}>{this.state.resultCode}</Text>
          <Button
            title="蓝牙组件"
            onPress={() => {
              this.setState({ changeView: ComponentView.BLUE_TOOTH });

            }}
          />
          <Button
            title="通知栏"
            onPress={() => {
              RNPushNotification.presentLocalNotification({
                /* Android Only Properties */
                id: ''+0, // (optional) Valid unique 32 bit integer specified as string. default: Autogenerated Unique ID
                ticker: "My Notification Ticker", // (optional)
                autoCancel: true, // (optional) default: true
                largeIcon: "ic_launcher", // (optional) default: "ic_launcher"
                smallIcon: "ic_notification", // (optional) default: "ic_notification" with fallback for "ic_launcher"
                bigText: "My big text that will be shown when notification is expanded", // (optional) default: "message" prop
                subText: "This is a subText", // (optional) default: none
                color: "red", // (optional) default: system default
                vibrate: true, // (optional) default: true
                vibration: 300, // vibration length in milliseconds, ignored if vibrate=false, default: 1000
                tag: 'some_tag', // (optional) add tag to message
                group: "group", // (optional) add group to message
                ongoing: false, // (optional) set whether this is an "ongoing" notification
          
                /* iOS only properties */
                alertAction: 'view', // (optional) default: view
                category: null, // (optional) default: null
                userInfo: null, // (optional) default: null (object containing additional notification data)
                
                /* iOS and Android properties */
                title: "Local Notification", // (optional)
                message: "My Notification Message", // (required)
                playSound: false, // (optional) default: true
                soundName: 'default', // (optional) Sound to play when the notification is shown. Value of 'default' plays the default sound. It can be set to a custom sound such as 'android.resource://com.xyz/raw/my_sound'. It will look for the 'my_sound' audio file in 'res/raw' directory and play it. default: 'default' (default sound is played)
                number: '10', // (optional) Valid 32 bit integer specified as string. default: none (Cannot be zero)
                actions: null,// (Android only) See the doc for notification actions to know more
                routeName:"delivery",
                param:"{aass:ss}"
              });
 }}
          />
          <Button
            title="图片选择器-拍照"
            onPress={() => {
              const options = {
                quality: 1.0,
                maxWidth: 240,
                maxHeight: 320,
                saveFileName:"filenameHa",
                title: 'Select Avatar',
                customButtons: [{ name: 'fb', title: 'Choose Photo from Facebook' }],
                storageOptions: {
                  skipBackup: true,
                  path: 'images',
                },
              };

              // ImagePicker.showImagePicker(options, (response) => {
              //   console.log('Response = ', response);
              
              //   if (response.didCancel) {
              //     console.log('User cancelled image picker');
              //   } else if (response.error) {
              //     console.log('ImagePicker Error: ', response.error);
              //   } else if (response.customButton) {
              //     console.log('User tapped custom button: ', response.customButton);
              //   } else {
              //     const source = { uri: response.uri };
              
              //     // You can also display the image using data:
              //     // const source = { uri: 'data:image/jpeg;base64,' + response.data };
              
              //     this.setState({
              //       avatarSource: source,
              //     });
              //   }
              // });
              // Launch Camera:
              ImagePicker.launchCamera(options, (response) => {
                // Same code as in above section!
                 console.log(response);
              });
            }}
          />
          <Button
            title="图片选择器-选择图片"
            onPress={() => {
              const options = {
                title: 'Select Avatar',
                quality: 1.0,
                maxWidth: 1080,
                maxHeight: 1920,
                customButtons: [{ name: 'fb', title: 'Choose Photo from Facebook' }],
                storageOptions: {
                  skipBackup: true,
                  path: 'images',
                },
              };
              // Open Image Library:
              ImagePicker.launchImageLibrary(options, (response) => {
                // Same code as in above section!
                console.log(response);

              });
            }}
          />
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  coverlayout: {
    flex: 1,
    left: 0,
    top: 0,
    position: "absolute"
  },
  text: {
    backgroundColor: "#FF0"
  },
  bluetoothLayout: {
    flex: 1,
    left: 200,
    top: 200,
    width: 100,
    position: "absolute"
  }
});
export default DemoPage;

