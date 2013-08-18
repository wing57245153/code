package GameCore.events
{

    public class AppEvent
    {
        //===============================
        // 服务器连接通讯
        //===============================
        public static const REQ_LOGIN_REMOTE:String = "req_login_remote";
        public static const REG_REMOTE:String = "reg_remote";
        public static const REM_REMOTE:String = "rem_remote";
        public static const REQ_REMOTE:String = "req_remote";

        //===============================
        // 装载进度
        //===============================
        public static const LOADING_MODULE_BEGIN:String = "loading_module_begin";
        public static const LOADING_MODULE_END:String = "loading_module_end";
        public static const LOADING_UI_BEGIN:String = "loading_ui_begin";
        public static const LOADING_UI_END:String = "loading_ui_end";

        //===============================
        // 模块
        //===============================
        public static const MODULE_UNLOAD:String = "module_unload";
        public static const MODULE_REGISTER:String = "module_register";
        public static const MODULE_UNREGISTER:String = "module_unregister";
        public static const MODULE_LOAD_MODULE:String = "module_load_module";
        public static const MODULE_TOP_MODULE:String = "module_top_module";
        public static const MODULE_LOAD_STAGE:String = "module_load_stage";
        public static const MODULE_LOAD_AVATAR:String = "module_load_avatar";
        public static const MODULE_SHOW_WINDOW:String = "module_show_window";
        public static const MODULE_HIDE_WINDOW:String = "module_hide_window";

        public static const MODULE_M2M:String = "module_m2m";
        //===============================
        // 战斗
        //===============================
        public static const BATTLE_BEGIN:String = "battle_begin";
        public static const BATTLE_FINISH:String = "battle_finish";

        /**
         * 第一次进入场景
         */
        public static const ENTER_SCENE:String = "enter_scene";

        /**
         * 场景切换
         */
        public static const RELOAD_SCENE:String = "reload_scene";

        /**
         * 加载完角色自己
         */
        public static const SELF_READY:String = "self_ready";

        /**
         * 窗口模态通知
         */
        public static const MODAL_LOCK:String = "modal_lock";

        /**
         * 窗口去除模态通知
         */
        public static const MODAL_UNLOCK:String = "modal_unlock";

        /**
         * 退出并销毁剧情
         */
        public static const SCENE_DRAMA_END_AND_UNLOAD:String = "scene_drama_end_and_unload";
    }
}


