px4_add_board(
	PLATFORM nuttx
	VENDOR lectron
	MODEL pi5-autopilot
	LABEL default
	TOOLCHAIN arm-none-eabi
	ARCHITECTURE cortex-m7
	CONSTRAINED_FLASH
	CONSTRAINED_MEMORY
	ROMFSROOT px4fmu_common
	IO px4_io-v2_default
	TESTING
	UAVCAN_INTERFACES 2
	
	SERIAL_PORTS
		GPS1:/dev/ttyS0
		TEL1:/dev/ttyS6
		TEL2:/dev/ttyS4
		TEL3:/dev/ttyS1
		GPS2:/dev/ttyS7
		EXT2:/dev/ttyS3

	DRIVERS
		adc/ads1115
		adc/board_adc
		barometer # all available barometer drivers
		batt_smbus
		camera_capture
		camera_trigger
		cdcacm
		#differential_pressure # DISABLED to save flash
		#distance_sensor # DISABLED to save flash
		dshot
		gps
		#heater
		#imu # all available imu drivers
		imu/bosch/bmi270
		imu/invensense/icm42670p
		#irlock # DISABLED to save flash
		#lights # DISABLED to save flash
		#magnetometer # all available magnetometer drivers
		magnetometer/bosch/bmm350
		#ms5611
		#optical_flow # all available optical flow drivers
		#osd
		#pca9685 # DISABLED to save flash
		#pca9685_pwm_out # DISABLED to save flash
		#power_monitor/ina226 # DISABLED to save flash
		#power_monitor/ina228 # DISABLED to save flash
		#power_monitor/ina238 # DISABLED to save flash
		#power_monitor/pm_selector_auterion
		protocol_splitter
		pwm_out
		px4io
		rc_input
		#roboclaw
		#rpm/pca9685_pwm # DISABLED to save flash
		#safety_button
		#tap_esc
		tone_alarm
		#uavcan

	MODULES
		airspeed_selector
		#attitude_estimator_q # DISABLED to save flash (EKF2 is primary)
		battery_status
		#camera_feedback
		commander
		dataman
		ekf2
		#ekf2_multi_instance
		esc_battery
		events
		flight_mode_manager
		#fw_att_control # DISABLED to save flash (fixed wing not used)
		#fw_pos_control # DISABLED to save flash (fixed wing not used)
		gyro_calibration
		#gyro_fft # DISABLED to save flash
		land_detector
		#landing_target_estimator # DISABLED to save flash
		load_mon
		local_position_estimator # DISABLED to save flash (EKF2 is primary)
		logger
		mavlink
		mc_att_control
		mc_hover_thrust_estimator
		mc_pos_control
		mc_rate_control
		#micrortps_bridge
		navigator
		rc_update
		#rover_pos_control # DISABLED to save flash (rover not used)
		#sensors
		manual_control
		control_allocator
		flight_mode_manager
		#sih
		#simulation-in-hardware
		#temperature_compensation
		#test_ppm
		#uorb_graph
		#vtol_att_control

	SYSTEMCMDS
		bl_update
		dmesg
		dumpfile
		esc_calib
		gpio
		hardfault_log
		i2cdetect
		led_control
		mft
		mixer
		motor_ramp
		motor_test
		mtd
		nshterm
		param
		perf
		pwm
		reboot
		reflect
		sd_bench
		sd_stress
		system_time
		top
		topic_listener
		tune_control
		uorb
		usb_connected
		ver
		work_queue

	EXAMPLES
		#fake_magnetometer
		#fixedwing_control # Tutorial code from https://px4.io/dev/example_fixedwing_control
		#hello
		#hwtest # Hardware test
		#matlab_csv_serial
		#px4_mavlink_debug # Tutorial code from http://dev.px4.io/en/debug/debug_values.html
		#px4_simple_app # Tutorial code from http://dev.px4.io/en/apps/hello_sky.html
		#rover_steering_control # Rover example app
		#uuv_example_app
		#work_item
)
