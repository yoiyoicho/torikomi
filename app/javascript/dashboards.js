import Vue from 'vue/dist/vue.esm.js';
import VCalendar from 'v-calendar';
Vue.use(VCalendar);

new Vue({
  el: '#app',
  data: { 
    attrs: [
        {
          key: 'today',
          highlight: {
            backgroundColor: '#ff8080',
          },
          dates: new Date(),
          popover: {
            label: 'メッセージを表示できます',
          },
        }
    ],
  }
});